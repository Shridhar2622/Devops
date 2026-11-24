import generateRoomId from "../utills/createRoomId.js";
import Room from "./Room.js";

// ── Central storage for all active rooms ──────────
const rooms = new Map();

// ── Room Management ───────────────────────────────

export function createRoom(hostPlayer, settings = {}) {
    const roomId = generateRoomId();
    const room = new Room(roomId, hostPlayer, settings);
    rooms.set(roomId, room);
    return room;
}

export function getRoom(roomId) {
    return rooms.get(roomId);
}

export function deleteRoom(roomId) {
    if (rooms.has(roomId)) {
        rooms.delete(roomId);
    }
}

export function getRoomBySocketId(socketId) {
    for (const room of rooms.values()) {
        const found = room.players.find(p => p.socketId === socketId);
        if (found) return room;
    }
    return undefined;
}
