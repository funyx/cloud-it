import path from 'path';
import express from 'express';
import { Server, Socket } from 'socket.io';
import { createServer } from 'http';
import { ChildProcessWithoutNullStreams, spawn } from 'child_process';
import uuidMiddleware from './config/uuidMiddleware';
import morganMiddleware from './config/morganMiddleware';
import Logger from './lib/logger';
import { uuid } from 'uuidv4';

const app = express();
const server = createServer(app);
const io = new Server(server);

interface Processes {
    [key: string]: ChildProcessWithoutNullStreams
}

let processes: Processes = {};

app.use(uuidMiddleware);
app.use(morganMiddleware);

app.set("port", process.env.PORT || 3000);

app.get("/", (req, res) => {
    res.sendFile(path.resolve("./client/index.html"));
});

declare global {
    namespace NodeJS {
        interface EventEmitter {
            aws?: {};
        }
    }
}

io.on('connection', function (socket: Socket) {
    socket.on('cmd', (message) => {
        if (message.cmd && message.params) {

            const process_id: string = uuid();

            const cmd: ChildProcessWithoutNullStreams = spawn(message.cmd, message.params, {
                env: Object.assign(process.env, socket.aws),
                serialization: 'advanced'
            });

            processes[process_id] = cmd;

            socket.join(process_id);
            socket.emit('process_id', {
                process_id
            });

            cmd.stdout.on('data', (data) => io.in(process_id).emit('stdout', data));
            cmd.stdin.on('data', (data) => io.in(process_id).emit('stdin', data));
            cmd.stderr.on('data', (data) => {
                io.in(process_id).emit('stderr', data)
            });
            cmd.on('exit', () => {
                io.in(process_id).emit('exit');
                socket.leave(process_id);
                delete processes[process_id];
            });
        }
    })
    socket.on('stdin', (data) => {
        const process_id = data.process_id;
        const input = new TextDecoder('utf8').decode(data.value);
        if (undefined === processes[process_id]) {
            throw new Error(process_id + ' is not a valid process id');
        }

        processes[process_id].stdin.write(input);
    })

    socket.on('environment', (data: Record<string, string | null | undefined>) => {
        for (const [key, value] of Object.entries(data)) {
            if (
                '' === value
                || null === value
                || undefined === value
            ) {
                delete data[key];
            }
        }
        socket.aws = data;
        socket.emit('environment', socket.aws)
    })
});

server.listen(3000, function () {
    console.log("listening on http://localhost:3000");
});
