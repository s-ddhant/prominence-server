# Prominence II server — one-click host

Prominence™ II: Hasturian Era **v4.1.4** (Fabric 1.20.1) server, tuned for a dedicated 16 GB PC.

## First-time setup (host PC)

1. **Download this repo**: green **Code** button → **Download ZIP** → extract it somewhere with ~5 GB free (e.g. `D:\Prominence`).
2. **Double-click `START-SERVER.bat`.**
   - First run downloads Java 17 + the server pack (~1.8 GB total) — takes a while.
   - It applies the tuned settings, generates a fresh world and starts the server.
   - If Windows Firewall asks about Java, click **Allow**.
3. **playit.gg** (lets friends connect):
   - Install the agent from https://playit.gg/download and sign in / claim it.
   - The tunnel owner moves the existing Minecraft tunnel to this agent in the playit dashboard
     (so friends keep the same address), or creates a new **Minecraft Java** tunnel → local port **25565**.

## Every time after

1. Make sure playit is running (tray icon).
2. Double-click **`START-SERVER.bat`**.
3. To shut down: type **`stop`** in the server window and wait for it to finish. Don't just close the window — that can lose progress.

## Notes

- Server uses **8 GB RAM**. Don't play Minecraft on this same PC while hosting.
- Turn off **Sleep** in Windows power settings while hosting, or the server goes down.
- Friends must use the **CurseForge** build of Prominence II **v4.1.4** — exact match.
- The next pack update removes Bumblezone and Deeper and Darker. Don't update until everyone agrees. When you do update, back up `server\world` first.
- Settings live in `config/` (copied into `server/` on start). Edit RAM in `config/variables.txt` → `JAVA_ARGS`.
