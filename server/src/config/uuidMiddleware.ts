import { uuid } from 'uuidv4';

declare global {
    namespace Express {
        interface Request {
            uuid?: string
        }
    }
}

const uuidMiddleware = (req: Express.Request, res: Express.Response, next: Function) => {
    req.uuid = uuid()
    next()
}

export default uuidMiddleware;