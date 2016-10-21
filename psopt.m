%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Jean Vitor de Paulo
%Genetic Algorithm for a Power Flow problem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function psopt(fhd,ii,jj,kk,args)
global proc
global ps
% Reinitialization of local
% function evaluation counter.
proc.i_eval=0;
% Function evaluation at which
% the last update of the global
% best solution occurred.
% Refers to the internal evaluation
% using static penalty constraint
% handling method.
proc.last_improvement=1;
% Signalizing your
% to stop running.
proc.finish=0;
% Size of the swarm.
n_par=proc.pop_size;
% For dynamic weight adaption.
me=proc.n_eval;
% Dimensionality of test case.
D=ps.D;
% Individuals' lower bounds.
VRmin=ps.x_min;
% Individuals' upper bounds.
VRmax=ps.x_max;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Individuals' type.
VRType = ps.x_type;

numVizinhos=20; %numero de vizinhos que ser�o procurados em cada indiv�duo

if length(VRmin)==1
    VRmin=repmat(VRmin,1,D);
    VRmax=repmat(VRmax,1,D);
end
VRmin=repmat(VRmin,n_par,1);
VRmax=repmat(VRmax,n_par,1);
Vmin=VRmin;
Vmax=VRmax;
%gerando popula��o inicial
pos=VRmin+(VRmax-VRmin).*rand(n_par,D);

%defini��o do vetor da popula��o que conter� a popula��o ap�s a sele��o
novaPop=pos;

%calculando par�metros
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fit,obj,g_sum,pos,fit_best]=feval(fhd,ii,jj,kk,args,pos);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%inicio do processo iterativo
while 1
    %%%%%%%
    
    %fazendo sele��o por torneio para a popula��o
    for i=1:n_par
        
        %escolhe aleatoriamente indiv�duos para os jogos, realizados 2 em 2
        individuoI=(round(rand(1)*n_par));
        individuoII=(round(rand(1)*n_par));
        if individuoI==0
            individuoI=1;
        end
        if individuoII==0
            individuoII=1;
        end
        
        %escolhendo o melhor
        if (fit(individuoI)<fit(individuoII))
            novaPop(i,:)=pos(individuoI,:);
        else
            novaPop(i,:)=pos(individuoII,:);
        end
    end
    
    %criando a estrutura onde ocorrer� a recombina��o
    populacaoRecombinada=novaPop;
    
    
    %iniciando processo
    for i=1:D
        %sorteando um ponto para recombina��o
        ponto=(round(rand(1)*D))-1;
        if (ponto<=0)
            ponto=1;
        end
        
        %invertendo a faixa de valores sorteada
        for i=1:n_par-1
            %recombinando o indiv�duo atual com o pr�ximo da lista
            for k=1:ponto
                populacaoRecombinada(i,k)=novaPop(i,k);
            end
            for k=ponto+1:D
                populacaoRecombinada(i,k)=novaPop(i+1,k);
            end
            
            for k=1:ponto
                populacaoRecombinada(i+1,k)=novaPop(i+1,k);
            end
            for k=ponto+1:D
                populacaoRecombinada(i+1,k)=novaPop(i,k);
            end
            i=i+1;
        end
        %%%%%%%%%%%%%%
    end
    
    %mutacao
    for i=1:n_par
        %considerando 1 pra mutar e 0 para n�o mutar para cada
        %indiv�duo
        podeMutar=round(rand(1));
        if podeMutar==1
            posicaoSorteada=round(rand(1)*D); %sorteia uma posi��o inicial para mutar
            if posicaoSorteada<=0
                posicaoSorteada=1;
            end
            if (VRType(posicaoSorteada)==0)    %se for um elmento cont�nuo, troca por outro do mesmo tipo
                for k=1:D
                    if VRType(k)==0
                        troca=populacaoRecombinada(k,posicaoSorteada);
                        populacaoRecombinada(k,posicaoSorteada)=populacaoRecombinada(i,posicaoSorteada);
                        populacaoRecombinada(i,posicaoSorteada)=troca;
                    end
                end
            end
            if (VRType(posicaoSorteada)==1)  %se for um elmento inteiro, troca por outro do mesmo tipo
                for k=1:D
                    if VRType(k)==1
                        troca=populacaoRecombinada(k,posicaoSorteada);
                        populacaoRecombinada(k,posicaoSorteada)=populacaoRecombinada(i,posicaoSorteada);
                        populacaoRecombinada(i,posicaoSorteada)=troca;
                    end
                end
            end
            if (VRType(posicaoSorteada)==2) %se for um elemento bin�rio, troca seu estado
                if populacaoRecombinada(i,posicaoSorteada)==0
                    populacaoRecombinada(i,posicaoSorteada)=1;
                else populacaoRecombinada(i,posicaoSorteada)=0;
                end
            end
        end
    end
    if proc.finish
        return;
    end
    %%%%%%%%%%%%%%
    
    % To prematurely stop
    % running the current trial,
    % you may use a statement
    % as the following.
    % However, note that
    % storage of intermediate
    % results must be done
    % manually since no ASCII
    % file output will be
    % provided in that case.
    % As an example, retrieve
    % relevant information
    % from cell array res.
    %         %%%%%%%%%%%%%%%%%%%%
    %         if proc.i_eval>=1000
    %             return;
    %         end
    %         %%%%%%%%%%%%%%%%%%%%
    
    
    %iniciando fase de melhoria local 2-opt para todos os individuos
    pos=populacaoRecombinada;
    buscaTemp=pos;
    cont=1;
    
    %buscando posi��es de tipos diferentes para utilizar como marcadores
    for y=1:D
        if VRType(y)==0
            posInicial=y;
            break;
        end
    end
    
    for x=1:D
        if VRType(x)==1
            posFinal=x;
            break;
        end
    end
    
    for i=1:n_par %percorrendo toda a popula��o
        buscaTemp=pos(i,:);
        solucaoAtual=buscaTemp;
        solucaoVizinha=buscaTemp;
        fit_bestTemp=fit(i);
        while cont<=numVizinhos %enquanto n�o procurar a quantidade total de vizinhos
            %sorteando posi�ao inicial e final para aplicar 2-opt
            % fprintf('%d ',pos(1,:));
            % fprintf('\n ');
            % fprintf('%d ',buscaTemp(1,:));
            while ((VRType(posInicial)~=VRType(posFinal)) ) %sorteando posi��es que sejam do mesmo VRtype
                posInicial=(round(rand(1)*D));
                posFinal=(round(rand(1)*D));
                if posInicial==0
                    posInicial=1;
                end
                if posFinal==0
                    posFinal=1;
                end
                if posInicial>posFinal
                    troca=posInicial;
                    posInicial=posFinal;
                    posFinal=troca;
                end
            end
            % fprintf('2-OPT na posi��o %d at� %d\n',posInicial,posFinal)
            inverso=posFinal;
            %invertendo a faixa de valores sorteada
            for k=posInicial:posFinal
                troca=solucaoVizinha(1,inverso);
                solucaoVizinha(1,inverso)=solucaoVizinha(1,k);
                solucaoVizinha(1,k)=troca;
                inverso=inverso-1;
            end
            args{3}=1;
            %Calculando fun��o objetivo da solu��o vizinha
            [fitTemp,objTemp,g_sumTemp,solucaoVizinha,fit_best]=feval(fhd,ii,jj,kk,args,solucaoVizinha);
            
            
            if (fitTemp>fit_bestTemp) %se o vizinho for pior
                cont=cont+1;
                solucaoVizinha=solucaoAtual;
            else
                %se o vizinho for melhor
                %fprintf ('Vizinho de melhor qualidade encontrado!%d\n ',fit_best);
                solucaoAtual=solucaoVizinha; %se a solu��o for melhor, ent�o os vizinhos ser�o procurados a partir dela
                cont=cont+1;
                
            end
            posInicial=y;
            posFinal=x;
        end
        pos(i,:)=solucaoAtual(1,:);
    end
    args{3}=n_par;
    %recalculando as fun��es da popula��o
    [fit,obj,g_sum,pos,fit_best]=feval(fhd,ii,jj,kk,args,pos);
end
end
