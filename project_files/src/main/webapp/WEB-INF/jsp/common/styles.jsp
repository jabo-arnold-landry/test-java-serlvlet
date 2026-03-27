<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
    :root { --sidebar-width:260px; --sidebar-bg:#1a1d23; --topbar-height:60px; --body-bg:#f0f2f5; --card-bg:#fff; --accent-blue:#3b82f6; --accent-green:#10b981; --accent-orange:#f59e0b; --accent-red:#ef4444; }
    * { font-family:'Inter',sans-serif; }
    body { background:var(--body-bg); }
    .sidebar { position:fixed;top:0;left:0;width:var(--sidebar-width);height:100vh;background:var(--sidebar-bg);color:#fff;overflow-y:auto;z-index:1000; }
    .sidebar-brand { padding:20px;border-bottom:1px solid rgba(255,255,255,0.1);display:flex;align-items:center;gap:12px; }
    .sidebar-brand .brand-icon { width:40px;height:40px;background:linear-gradient(135deg,var(--accent-blue),#8b5cf6);border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:20px; }
    .sidebar-brand h5 { margin:0;font-weight:700;font-size:16px; }
    .sidebar-brand small { font-size:11px;color:rgba(255,255,255,0.5); }
    .sidebar-nav { padding:15px 12px; }
    .nav-section-label { font-size:10px;text-transform:uppercase;letter-spacing:1.5px;color:rgba(255,255,255,0.35);padding:15px 15px 8px;font-weight:600; }
    .sidebar-nav .nav-link { color:rgba(255,255,255,0.7);padding:10px 15px;border-radius:8px;margin-bottom:2px;font-size:14px;display:flex;align-items:center;gap:12px;transition:0.2s;text-decoration:none; }
    .sidebar-nav .nav-link:hover { color:#fff;background:#2d3139; }
    .sidebar-nav .nav-link.active { color:#fff;background:var(--accent-blue);font-weight:500; }
    .sidebar-nav .nav-link i { font-size:18px;width:22px;text-align:center; }
    .topbar { position:fixed;top:0;left:var(--sidebar-width);right:0;height:var(--topbar-height);background:var(--card-bg);border-bottom:1px solid #e5e7eb;display:flex;align-items:center;justify-content:space-between;padding:0 30px;z-index:999; }
    .main-content { margin-left:var(--sidebar-width);margin-top:var(--topbar-height);padding:30px; }
    .stat-card { background:var(--card-bg);border-radius:12px;padding:20px;border:1px solid #e5e7eb;transition:0.2s; }
    .stat-card:hover { box-shadow:0 4px 12px rgba(0,0,0,0.08);transform:translateY(-2px); }
    .table-container { background:var(--card-bg);border-radius:12px;border:1px solid #e5e7eb;overflow:hidden; }
    .table-container .table { margin:0; }
    .table-container .table th { background:#f9fafb;font-weight:600;font-size:12px;text-transform:uppercase;letter-spacing:0.5px;color:#6b7280;border-bottom:2px solid #e5e7eb;padding:12px 16px; }
    .table-container .table td { padding:12px 16px;font-size:14px;vertical-align:middle; }
    .user-avatar { width:35px;height:35px;border-radius:50%;background:linear-gradient(135deg,var(--accent-blue),#8b5cf6);display:flex;align-items:center;justify-content:center;color:#fff;font-weight:600;font-size:14px; }
    @media (max-width:768px) { .sidebar{transform:translateX(-100%);} .topbar{left:0;} .main-content{margin-left:0;} }
    @media print {
        .sidebar, .topbar, .btn { display: none !important; }
        .main-content { margin: 0 !important; padding: 0 !important; }
        .table-container { border: none !important; box-shadow: none !important; }
        body { background: #fff !important; }
        @page { size: landscape; margin: 10mm; }
    }
</style>
