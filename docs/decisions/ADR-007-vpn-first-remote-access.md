# ADR-007: VPN-first Remote Access

Status: Accepted

遠端 SSH 僅經核准的 VPN Overlay 網路提供，不直接把路由器 SSH Port 暴露至 Internet；再以 Public Key 與 ACL 實作縱深防禦。
