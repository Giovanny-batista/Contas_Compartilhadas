const express = require('express');
const app = express();
const port = 3000;

// Configura a rota para a confirmação
app.get('/confirmar', (req, res) => {
  const grupoId = req.query.grupo_id;
  const email = req.query.email;

  // Adicione a lógica para adicionar o usuário ao grupo aqui

  // Simples resposta de confirmação
  res.send(`Você foi adicionado ao grupo com ID: ${grupoId} com sucesso!`);
});

app.listen(port, () => {
  console.log(`Servidor rodando na porta ${port}`);
});
