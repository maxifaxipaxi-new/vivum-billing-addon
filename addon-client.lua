local function checkAndPayOldInvoices(playerId)
    exports["vivum-billing"]:FetchInvoices(playerId, "received", { id = "__me", label = "Me" }, function(res)
        if res.status == "OK" then
            for _, invoice in ipairs(res.invoices) do
                local invoiceTimestamp = os.time({year = tonumber(string.sub(invoice.timestamp, 1, 4)),
                                                  month = tonumber(string.sub(invoice.timestamp, 6, 7)),
                                                  day = tonumber(string.sub(invoice.timestamp, 9, 10)),
                                                  hour = tonumber(string.sub(invoice.timestamp, 12, 13)),
                                                  min = tonumber(string.sub(invoice.timestamp, 15, 16)),
                                                  sec = tonumber(string.sub(invoice.timestamp, 18, 19))})
                local currentTime = os.time()

                if currentTime - invoiceTimestamp > 3 * 24 * 60 * 60 and invoice.status ~= "paid" then
                    local invoiceData = {
                        id = invoice.id,
                        sender = invoice.sender,
                        sender_label = invoice.sender_label,
                        recipient = invoice.recipient,
                        recipient_label = invoice.recipient_label,
                    }

                    exports["vivum-billing"]:PayInvoice(playerId, invoiceData, function(paymentRes)
                        if paymentRes.status == "OK" then
                            print("Rechnung ID " .. invoice.id .. " wurde automatisch bezahlt.")
                        else
                            print("Fehler beim Bezahlen der Rechnung ID " .. invoice.id)
                        end
                    end)
                end
            end
        else
            print("Fehler beim Abrufen der Rechnungen.")
        end
    end)
end

AddEventHandler('esx:playerLoaded', function(playerId)
    Citizen.Wait(300000)
    checkAndPayOldInvoices(playerId)
end)
