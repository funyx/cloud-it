import winston from 'winston';

const { addColors, createLogger, format, transports } = winston;
const { combine, splat, timestamp, printf } = format;

addColors({
    error: 'red',
    warn: 'yellow',
    info: 'green',
    http: 'magenta',
    debug: 'white',
    verbose: 'gray',
});

const levels = {
    error: 0,
    warn: 1,
    info: 2,
    http: 3,
    debug: 4,
    verbose: 5,
}

const level = () => {
    const env = process.env.NODE_ENV || 'development'
    const isDevelopment = env === 'development'
    return isDevelopment ? 'verbose' : 'warn'
}

const printer = printf((props) => {
    const { level, message, timestamp, ...metadata } = props;

    let msg = `[${level}] ${timestamp} : ${message}`

    if (metadata) {
        const stringify = JSON.stringify(metadata);
        if (stringify && stringify != '{}') {
            msg += JSON.stringify(metadata)
        }
    }

    return msg
});

const logFormat = combine(
    splat(),
    timestamp(),
    printer
);

const logChannels = [
    new transports.Console({
        format: combine(logFormat, format.colorize({
            all: true
        }))
    }),
    new transports.File({
        filename: 'logs/error.log',
        level: 'error'
    }),
    new transports.File({
        filename: 'logs/all.log'
    }),
]

const Logger = createLogger({
    level: level(),
    levels,
    format: logFormat,
    transports: logChannels
})

export default Logger