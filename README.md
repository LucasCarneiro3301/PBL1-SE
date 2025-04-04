# README - Código Assembly para 8051

(Arquivo principal: semaforo_novo.asm)

## Alunos
Ian Zaque Santos e Lucas Carneiro de Araújo Lima 

## Visão Geral
Este repositório contém um código Assembly para o microcontrolador 8051, implementando um sistema de exibição em displays de 7 segmentos multiplexados. O código também controla LEDs de indicação e recebe entradas de chaves DIP.

## Funcionalidade do Código
O sistema exibe números decrescentes em um conjunto de quatro displays de 7 segmentos multiplexados. Além disso, há controle de LEDs indicativos e resposta a chaves DIP para interações externas.

### Componentes e Portas Utilizadas:
- **P0 (Bits 0, 1)**: Controle do multiplexador dos displays de 7 segmentos.
- **P1 (Todos os 8 bits)**: Controle dos segmentos do display.
- **P2 (Bits 0, 1, 2)**: LEDs de indicação.
- **P3 (Bits 2, 3)**: Chaves DIP para entrada de usuário.

## Como o Sistema Funciona
1. **Multiplexação dos Displays de 7 Segmentos**:
   - Cada dígito é ativado sequencialmente através dos bits de controle em **P0**.
   - Os segmentos do display são definidos por **P1**, conforme uma tabela de mapeamento binário.
   - O sistema atualiza os dígitos periodicamente para simular a exibição contínua dos números.

2. **Controle de LEDs (P2)**:
   - Diferentes valores são escritos em **P2** para ativar ou desativar LEDs de status.
   - Cada bit representa um LED específico.

3. **Leitura de Chaves DIP (P3)**:
   - As chaves DIP em **P3.2 e P3.3** determinam certas condições do sistema.
   - Estão associadas a rotinas de interrupção.
   - O sistema reage às mudanças das chaves, podendo realizar uma contagem ou iniciar o a rotina de sinal vermelho com 15 segundos de duração.

## Como Executar
### Requisitos:
- Um microcontrolador 8051 ou um simulador compatível (Keil uVision, Proteus, etc.).
- Ambiente de desenvolvimento Assembly (ex: Keil uVision, ASM51).

### Passo a Passo:
1. Clone este repositório:
   ```sh
   git clone https://github.com/seu-usuario/nome-do-repositorio.git
2. Abra o arquivo `.asm` em um ambiente de desenvolvimento compatível.
3. Compile o código Assembly.
4. Carregue o binário no simulador ou grave no microcontrolador 8051.
5. Carregue os arquivos de configuração do display de 7 segmentos, chaves e LEDs.
6. Execute o código e observe os displays de 7 segmentos, LEDs e chaves DIP em ação.

## Comportamento do Sistema
- O número exibido nos displays começa a contar regressivamente.
- Diferentes sequências de LEDs indicam estados do sistema (sinais verde, amarelo e vermelho).
- Alterando as chaves DIP, o usuário pode iniciar a rotina do sinal vermelho com duração de 15 sega contagem ou contar o fluxo de veículos.

## Personalização
- Para alterar os números exibidos, edite a tabela de números na seção `numbers`.
- Modifique os tempos de exibição alterando as chamadas de **DELAY**.
- Ajuste a resposta às chaves DIP conforme necessário dentro das interrupções.
