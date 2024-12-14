module projeto

//=================//
//  ESPECIFICAÇÃO  //
//=================//

A UFCG vai implantar um sistema de reserva dos laboratórios LCC1 e LCC2 semanalmente.

As reservas só podem ser feitas com duração de duas horas por dia. 
Os quatro horários possíveis:

8h-10h, 10h-12h, 14h-16h, 16h-18h (nos 5 dias úteis da semana).

Se o professor reservar, é que tem uma disciplina associada, 
com dois horários semanais.

Existe uma lista de espera por horário e por sala. 
Em nenhum momento a lista de espera tem um horário de disciplina 
enquanto outro horário sem disciplina está usando a sala. 
Um pedido da lista de espera para um dos LCCs pode ser
contemplado em outro LCC se houver horário disponível.
*/


//==========================//
// DEFINIÇÃO DE ASSINATURAS //
//==========================//

// Representa uma pessoa no sistema (professor, aluno, etc.).
sig Pessoa { }

// Representa um professor, que deve ter pelo menos uma disciplina.
sig Professor extends Pessoa {
    disciplinas: disj some Disciplina
} {
	#disciplinas >= 1
}

// Representa uma disciplina associada a professores e pedidos.
sig Disciplina { }

// Classe abstrata para laboratórios no sistema.
abstract sig Laboratorio { }

// Instâncias de laboratórios disponíveis para reserva.
one sig LCC1, LCC2 extends Laboratorio { }

// Classe base para horários.
abstract sig Horario { }

// Horários disponíveis em faixas de duas horas para cada dia útil.
one sig SegH8A10, SegH10A12, SegH14A16, SegH16A18 extends Horario { }
one sig TerH8A10, TerH10A12, TerH14A16, TerH16A18 extends Horario { }
one sig QuaH8A10, QuaH10A12, QuaH14A16, QuaH16A18 extends Horario { }
one sig QuiH8A10, QuiH10A12, QuiH14A16, QuiH16A18 extends Horario { }
one sig SexH8A10, SexH10A12, SexH14A16, SexH16A18 extends Horario { }

// Representa um dia com 4 horários fixos.
abstract sig Dia { 
    horarios: set Horario
} { 
    #horarios = 4
}

// Dias úteis da semana.
one sig Segunda, Terça, Quarta, Quinta, Sexta extends Dia { }

// Representa um pedido de reserva de laboratório.
sig Pedido {
    solicitante: one Pessoa,          // Quem faz o pedido
    laboratorio: one Laboratorio,     // Laboratório solicitado
    dias: set Dia,                    // Dias da reserva
    horarios: set Horario,            // Horários da reserva
    disciplina: lone Disciplina       // Disciplina associada, se houver
} { }

// Lista de reservas confirmadas.
one sig ListaReserva {
    pedidos: disj set Pedido          // Pedidos confirmados
}

// Lista de pedidos em espera.
one sig ListaEspera {
    pedidos: disj set Pedido          // Pedidos aguardando
}


//=========================//
//   DEFINIÇÃO DE FATOS    //
//=========================//

// Fato que associa horários a dias específicos da semana.
fact "Horários dos Dias" {
    Segunda.horarios = SegH8A10 + SegH10A12 + SegH14A16 + SegH16A18
    Terça.horarios = TerH8A10 + TerH10A12 + TerH14A16 + TerH16A18
    Quarta.horarios = QuaH8A10 + QuaH10A12 + QuaH14A16 + QuaH16A18
    Quinta.horarios = QuiH8A10 + QuiH10A12 + QuiH14A16 + QuiH16A18
    Sexta.horarios = SexH8A10 + SexH10A12 + SexH14A16 + SexH16A18
}

// Fato que associa disciplinas a professores.
fact "Disciplinas dos Professores" {
	todasDisciplinasAssociadasAUmProfessor[]
}


//=========================//
//   RESTRIÇÕES GERAIS     //
//=========================//

// Restrições que definem as regras gerais para pedidos de reserva.
fact "Limitantes de Pedido" {
	// Restrições para cada pedido individualmente.
	all ped: Pedido {
		horariosCorretos[ped]          // Verifica se os horários estão dentro dos dias solicitados.
		disciplinaValida[ped]          // Garante que a disciplina é válida para professores.
		naoProfessorSemDisciplina[ped] // Não permite disciplinas associadas a não-professores.
		validaDiasEHorarios[ped]       // Confere a consistência de dias e horários para o solicitante.
		pedidoEmLista[ped]             // O pedido deve estar em uma das listas (espera ou reserva).
		validaRelacaoListas[ped]       // Garante a relação entre listas de reserva e espera.
		conflitoHorariosNaEspera[ped]  // Restrições de conflitos entre listas de espera e reserva.
    }

	// Restrições para pares de pedidos.
	all disj ped1, ped2: Pedido {
		semConflitoDeHorarios[ped1, ped2] // Garante que não haja conflito de horários entre pedidos.
		aulaTemPrioridade[ped1, ped2]     // As aulas têm prioridade sobre pedidos sem aula.
		semPedidosDuplicados[ped1, ped2]  // Garante que um solicitante não tenha dois pedidos com horários sobrepostos em laboratórios diferentes.

  	}
}


//=========================//
// DEFINIÇÃO DE PREDICADOS //
//=========================//

// Verifica se os horários de um pedido correspondem aos dias solicitados.
// Garante que todos os horários do pedido estão válidos para os dias especificados.
pred horariosCorretos(pedido: Pedido) {
	all dia: pedido.dias | 
		one horario: pedido.horarios | horario in dia.horarios
}

// Garante que toda disciplina existente está associada a um professor.
pred todasDisciplinasAssociadasAUmProfessor() {
	all disciplina: Disciplina | 
		some professor: Professor | disciplina in professor.disciplinas
}

// Para pedidos de professores, garante que a disciplina é válida.
// A disciplina deve estar entre as disciplinas do professor solicitante.
pred disciplinaValida(pedido: Pedido) {
    (pedido.solicitante in Professor and pedido.disciplina != none) implies 
        (pedido.disciplina in pedido.solicitante.disciplinas)
}

// Restringe não-professores a não terem disciplinas associadas.
// Se o solicitante não for professor, a disciplina deve ser `none`.
pred naoProfessorSemDisciplina(pedido: Pedido) {
    (pedido.solicitante not in Professor) implies (pedido.disciplina = none)
}

// Garante que o número de dias e horários no pedido seja consistente com o tipo de solicitante.
// Professores têm 2 dias e 2 horários; não-professores têm apenas 1 dia e 1 horário.
pred validaDiasEHorarios(pedido: Pedido) {
    (pedido.solicitante in Professor and pedido.disciplina != none) implies 
        (#pedido.dias = 2 and #pedido.horarios = 2) else
    (pedido.solicitante not in Professor or pedido.disciplina = none) implies 
        (#pedido.dias = 1 and #pedido.horarios = 1)
}

// Garante que o pedido esteja presente em uma das listas (reserva ou espera), mas não em ambas.
// Esta restrição impede que um pedido esteja fora das listas de controle.
pred pedidoEmLista(pedido: Pedido) {
    pedido in (ListaEspera.pedidos + ListaReserva.pedidos)
}

// Verifica a relação entre as listas de espera e de reserva.
// Um pedido só pode estar em uma das listas, nunca em ambas ao mesmo tempo.
pred validaRelacaoListas(pedido: Pedido) {
    pedido in ListaReserva.pedidos iff pedido not in ListaEspera.pedidos
}

// Garante que um pedido em espera não entre em conflito de horários com pedidos já reservados.
pred conflitoHorariosNaEspera(pedido: Pedido) {
    pedido in ListaEspera.pedidos implies (
        some disj pedidoReserva: Pedido |
            pedidoReserva in ListaReserva.pedidos and
            TemIntersecaoDeHorarios[pedido, pedidoReserva] and
            (pedido.laboratorio = pedidoReserva.laboratorio)
    )
}

// Verifica se dois pedidos de reserva não têm conflito de horários.
// Se ambos são de reserva e no mesmo laboratório, não podem ter horários sobrepostos.
pred semConflitoDeHorarios(pedido1, pedido2: Pedido) {
    (pedido1 in ListaReserva.pedidos and pedido2 in ListaReserva.pedidos) implies (
        (pedido1.laboratorio = pedido2.laboratorio) implies 
            no (pedido1.horarios & pedido2.horarios)
    )
}

// Garante que pedidos de aula têm prioridade sobre pedidos que não são de aula.
// Se um pedido de aula e um sem disciplina têm interseção de horários no mesmo laboratório,
// o pedido de aula não pode estar na lista de espera enquanto o pedido sem disciplina está na lista de reserva.
pred aulaTemPrioridade(pedidoAula, pedidoNaoAula: Pedido) {
    (pedidoAula.disciplina != none and pedidoNaoAula.disciplina = none and
    TemIntersecaoDeHorarios[pedidoAula, pedidoNaoAula] and
    pedidoAula.laboratorio = pedidoNaoAula.laboratorio) implies
        not (pedidoAula in ListaEspera.pedidos and pedidoNaoAula in ListaReserva.pedidos)
}

// Garante que um mesmo solicitante não possa criar pedidos com os mesmos horários.
pred semPedidosDuplicados(pedido1, pedido2: Pedido) {
    some (pedido1.horarios & pedido2.horarios) implies 
    (pedido1.solicitante != pedido2.solicitante and 
     pedido1.laboratorio != pedido2.laboratorio)
}


// Verifica se dois pedidos têm interseção nos horários.
pred TemIntersecaoDeHorarios(pedido1, pedido2: Pedido) {
    some (pedido1.horarios & pedido2.horarios)
}


//=========================//
//  DEFINIÇÃO DE ASSERTS   //
//=========================//

// Garante que toda disciplina existente está associada a um professor.
assert DisciplinasAssociadasAUmProfessor {
    todasDisciplinasAssociadasAUmProfessor[]
}

// Verifica se cada pedido de professor está associado a uma disciplina válida.
assert DisciplinaValida {
    all pedido: Pedido |
        (pedido.solicitante in Professor) implies (pedido.disciplina in pedido.solicitante.disciplinas)
}

// Garante que apenas professores podem fazer pedidos de laboratório com disciplina.
assert ProfessorSolicitaDisciplina {
    all pedido: Pedido |
        (pedido.disciplina != none) implies (pedido.solicitante in Professor)
}

// Assegura que não há conflitos de horários entre pedidos na lista de reserva para o mesmo laboratório.
assert TemPedidosNaListaReservaComMesmoHorarioParaAMesmaSala {
    all disj ped1, ped2: Pedido |
        (ped1 in ListaReserva.pedidos and ped2 in ListaReserva.pedidos) implies
        (ped1.laboratorio != ped2.laboratorio or no (ped1.horarios & ped2.horarios))
}

// Garante que pedidos de professores tenham horários distintos.
assert PedidosProfessor {
    all pedido: Pedido |
        (pedido.solicitante in Professor) and (pedido.disciplina != none) implies 
            (some disj hor1, hor2: pedido.horarios | hor1 != hor2)
}

// Limita o número de horários em um pedido de professor a no máximo dois.
assert PedidoProfessorComDoisHorariosNoMaximo {
    all pedido: Pedido |
        (pedido.solicitante in Professor) implies (#pedido.horarios <= 2)
}

// Restringe pedidos de não-professores a apenas um horário.
assert PedidosNaoProfessoresComUmHorarioNoMaximo {
    all pedido: Pedido |
        (pedido.solicitante not in Professor) implies (#pedido.horarios = 1)
}

// Garante que pedidos na lista de espera tenham interseção de horários com algum pedido na lista de reserva.
assert ReservaSempreQuePossivel {
    all pedido: Pedido |
        pedido in ListaEspera.pedidos implies (
            some disj pedidoReserva: Pedido |
                pedidoReserva in ListaReserva.pedidos and
                TemIntersecaoDeHorarios[pedido, pedidoReserva] and
                pedido.laboratorio = pedidoReserva.laboratorio
        )
}

// Impede duplicidade de horários na lista de reserva.
assert HorariosUnicosNaListaDeReserva {
    all disj pedido1, pedido2: Pedido | 
        (pedido1 in ListaReserva.pedidos and pedido2 in ListaReserva.pedidos) and
        (pedido1.laboratorio = pedido2.laboratorio) implies no (pedido1.horarios & pedido2.horarios)
}

// Prioriza pedidos com disciplina sobre aqueles sem disciplina.
assert PrioridadePedidosComDisciplina {
    all disj pedidoComDisciplina, pedidoSemDisciplina: Pedido |
        pedidoComDisciplina.disciplina != none and
        pedidoSemDisciplina.disciplina = none and
        TemIntersecaoDeHorarios[pedidoComDisciplina, pedidoSemDisciplina] and
        pedidoComDisciplina.laboratorio = pedidoSemDisciplina.laboratorio implies
        not (pedidoComDisciplina in ListaEspera.pedidos and pedidoSemDisciplina in ListaReserva.pedidos)
}

// Garante que um solicitante não tenha dois pedidos com horários coincidentes em diferentes laboratórios.
assert SolicitanteSemPedidosDuplicadosEmLaboratorios {
    all pedido1, pedido2: Pedido |
        (pedido1 in ListaReserva.pedidos and pedido2 in ListaReserva.pedidos) implies
        (pedido1.solicitante != pedido2.solicitante or pedido1.laboratorio = pedido2.laboratorio or 
         no (pedido1.horarios & pedido2.horarios))
}


//=========================//
//    SEÇÃO DE CHECKS      //
//=========================//

check DisciplinasAssociadasAUmProfessor for 15
check PedidosNaoProfessoresComUmHorarioNoMaximo for 15
check PedidoProfessorComDoisHorariosNoMaximo for 15
check PedidosProfessor for 15
check TemPedidosNaListaReservaComMesmoHorarioParaAMesmaSala for 15
check DisciplinaValida for 15
check ReservaSempreQuePossivel for 15
check HorariosUnicosNaListaDeReserva for 15
check PrioridadePedidosComDisciplina for 15
check SolicitanteSemPedidosDuplicadosEmLaboratorios for 15
check ProfessorSolicitaDisciplina for 15


//=========================//
//    SEÇÃO DE EXECUÇÃO    //
//=========================//

pred show[ ] { }
run show for 15

