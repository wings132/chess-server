local chest = {}


function chest.tcp_recvMsg()
    local server = require("cqueues.socket").listen({
        host = "0.0.0.0",
        port = "4567",
        reuseaddr = true,
        reuseport = true
    })

    local cqueuesss = require("cqueues").new()
    cqueuesss:wrap(function()
        for cli in server:clients() do

            print("Server收到新连接：",select(2, cli:peername()))

            local cq = require("cqueues").new()

            cq:wrap(function()
                local host, port = select(2, cli:peername())
                repeat
                    local buf = cli:read("*l")
                    if not buf or #buf==0 then
                        goto continue
                    end
                    print(string.format("收到%s:%d数据：%s",host,port,buf))
                    cli:write("\nserverMsg: "..buf.."\n")
                    ::continue::
                until  not buf
                print(string.format("client%s:%d主动断开连接",host,port))
            end)

            cqueuesss:wrap(function()
                cq:loop()
            end)

        end
    end)

    cqueuesss:loop()
end

function chest.tcp_sendMsg(host,port,msg)
    local client = require("cqueues.socket").connect(host, port)
    client:setmode("b","nb")
    client:connect()
    client:write(msg)
    print("send msg success")
end

return chest