# Sistema de Reserva de Laboratórios da UFCG

Este projeto é uma modelagem em Alloy de um sistema de reservas para os laboratórios LCC1 e LCC2 da UFCG. O sistema permite que professores e outras pessoas façam pedidos de reserva, com regras específicas para horários e uma lista de espera para os laboratórios.

## Especificação

- **Laboratórios disponíveis:** LCC1 e LCC2
- **Horários de reserva:** 8h-10h, 10h-12h, 14h-16h, 16h-18h (somente dias úteis)
- **Duração da reserva:** 2 horas por dia
- **Reservas para professores:** Associadas a uma disciplina e com dois horários semanais
- **Lista de espera:** Gerenciada para casos onde todos os horários estão ocupados

## Regras Gerais

1. **Horários fixos:** Os horários disponíveis estão restritos a 2 horas por dia.
2. **Prioridade de pedidos:** Reservas de professores com disciplina têm prioridade sobre outros pedidos.
3. **Lista de espera:** Um pedido em espera pode ser transferido entre os laboratórios se houver disponibilidade em outro.
4. **Conflitos de horários:** Não podem existir reservas com conflitos de horários no mesmo laboratório.
5. **Validação de disciplina:** Um professor pode associar disciplinas ao fazer pedidos de reserva.

## Estrutura do Projeto

- **Pessoa:** Representa quem faz o pedido de reserva (professores, alunos, etc.).
- **Professor:** Um tipo específico de pessoa que pode ter disciplinas associadas.
- **Disciplina:** Associa-se a professores e a pedidos de reserva de laboratório.
- **Laboratório:** Instâncias de laboratórios disponíveis para reserva (LCC1 e LCC2).
- **Dia e Horário:** Define os dias úteis e os horários disponíveis para reserva.
- **Pedido:** Representa um pedido de reserva de laboratório, incluindo solicitante, horários e, opcionalmente, uma disciplina.
- **ListaReserva e ListaEspera:** Gerencia os pedidos de reserva confirmados e os pedidos aguardando na lista de espera.

## Instalação

1. Instale o Alloy: [https://alloytools.org/download.html](https://alloytools.org/download.html)
2. Clone este repositório.
3. Abra o arquivo `.als` no Alloy e execute as análises.

## Executando o Modelo

- Para verificar as propriedades do sistema, basta abrir o arquivo `.als` no Alloy e rodar as assertivas e predicados.
- Use os comandos no Alloy para testar cenários e garantir que as restrições estão sendo cumpridas.

## Contribuidores

- Lázaro Queiroz do Nascimento - 123110628
- Igor Raffael Menezes de Melo - 123110549
- Rafael Barreto da Silva - 123110738
- Antônio Barros de Alcantara Neto - 123110363
- Matheus Galdino de Souza - 123111147

## Licença

Este projeto é para fins acadêmicos e segue as regras estabelecidas pela UFCG.
