$response = Invoke-WebRequest http://localhost:8084
if ($response.Content -match "Version") {
  Write-Output " App responds with version message"
} else {
  Write-Output " App did not return expected content"
}
