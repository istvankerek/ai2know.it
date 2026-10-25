/**
 * WebSocket real-time ertesitesek kliens
 */

type NotificationHandler = (data: unknown) => void;

export class WebSocketClient {
  private ws: WebSocket | null = null;
  private handlers: Map<string, NotificationHandler[]> = new Map();
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;

  constructor(private url: string) {}

  /** Kapcsolodas */
  connect(): void {
    this.ws = new WebSocket(this.url);

    this.ws.onmessage = (event) => {
      const message = JSON.parse(event.data);
      const handlers = this.handlers.get(message.type) || [];
      handlers.forEach((handler) => handler(message.data));
    };

    this.ws.onclose = () => {
      if (this.reconnectAttempts < this.maxReconnectAttempts) {
        this.reconnectAttempts++;
        setTimeout(() => this.connect(), 1000 * this.reconnectAttempts);
      }
    };

    this.ws.onopen = () => {
      this.reconnectAttempts = 0;
    };
  }

  /** Feliratkozas ertesites tipusra */
  on(type: string, handler: NotificationHandler): void {
    const existing = this.handlers.get(type) || [];
    this.handlers.set(type, [...existing, handler]);
  }

  /** Kapcsolat bontasa */
  disconnect(): void {
    this.ws?.close();
    this.ws = null;
  }
}
