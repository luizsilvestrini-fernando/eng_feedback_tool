# Documentação de Produto - Eng Feedback Tool

O **Eng Feedback Tool** é uma plataforma interna da Ótmow Engenharia projetada para institucionalizar e escalar o processo de feedback e evolução técnica da equipe.

## 🚀 Proposta de Valor
- **Transparência**: Alinhamento claro entre engenheiro e gestor sobre expectativas e realidade.
- **Histórico**: Acompanhamento da evolução técnica através de gráficos e registros temporais.
- **Padronização**: Uma matriz de competência unificada que serve como "regra do jogo".

---

## 👥 Papéis e Permissões

| Papel | Descrição | Principais Ações |
| :--- | :--- | :--- |
| **Engineer (User)** | O colaborador em avaliação. | Preencher Matriz, baixar seus PDFs, ver Dashboard. |
| **Manager (Gestor)** | Liderança técnica/gestão. | Criar Feedbacks, Gerenciar Ciclos, Ver médias do time. |
| **Admin** | Superusuário. | Tudo do Gestor + Gestão de Usuários e Reset de Matriz. |

---

## 🌊 Fluxos Principais

### 1. Ciclo de Feedback Mensal/Trimestral
1. **Preparação**: O Gestor cria um novo ciclo na Matriz de Competência.
2. **Autoavaliação**: O Engenheiro preenche sua matriz e submete (bloqueando a edição).
3. **Sessão 1:1**: O Gestor realiza a reunião, registra notas e comentários na aba "Novo Feedback".
4. **Finalização**: O Gestor salva e envia o PDF oficial por e-mail para o Engenheiro.

### 2. Acompanhamento de Evolução
1. O usuário (ou gestor) acessa a aba **Dashboard Evolutivo**.
2. O sistema plota gráficos de linha comparando os scores das últimas avaliações.
3. É possível ver em qual pilar técnico o engenheiro está evoluindo ou estagnando.

### 3. Matriz de Competência Técnica
- **Categorias**: Organizadas por pilares (ex: Qualidade, Execução, Soft Skills).
- **Indicadores de Tendência**: No modo Manager, setas coloridas indicam se o time está acima (🟢 ↑) ou abaixo (🔴 ↓) do *Target* definido para aquela competência.
- **Edição Inline**: Gestores podem ajustar definições da matriz em tempo real.

---

## 📋 Definições de Atributos (Matriz)
- **0 - Não conhece**: Nenhuma interação ou conhecimento prévio.
- **1 - Pouca experiência**: Conhece o conceito mas não domina a execução.
- **2 - Executa com domínio**: Realiza a tarefa com qualidade de forma autônoma.
- **3 - Domina e Ensina**: Referência técnica que compartilha conhecimento.
