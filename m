From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: Net containers config and usage
Date: Thu, 15 Jan 2009 23:21:43 +0100
Message-ID: <496FB6F7.9080906@free.fr>
References: <20090113191837.GA29900@versecorp.net> <496CF11A.7090908@free.fr>
	<20090113214747.GA23742@versecorp.net>
	<1231887220.6398.73.camel@groeck-laptop> <496DA755.1040001@free.fr>
	<20090114172739.GA13581@versecorp.net>
	<496E23DA.9080402@free.fr> <20090114192633.GA8572@us.ibm.com>
	<20090114193944.GA14129@versecorp.net> <496E42D6.2080306@free.fr>
	<20090115215900.GA30607@versecorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090115215900.GA30607-SqNQQPNds68nxqbYAscKCQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org wrote:
>>> Yes, ultimately we'll need the physical device inside the same namespace
>>> as our application.  Our application does a lot of management on the 
>>> interface,
>>> monitoring things like the interface's link-pulse and such, and that 
>>> wouldn't
>>> be available through a virtual interface.  We can always redesign things
>>> to have the management portion run in the namespace with the physical 
>>> interface,
>>> but for performance reasons we'd eventually want the physical interface to 
>>> be
>>> directly inside the namespace anyway - so that would probably be wasted 
>>> effort.
>>>  
>>>       
>> Did you tried with the macvlan ?
>>     
>
> I just tried it - and it does work - I can move the vlan interfaces into the
> namespace.   But that's not a solution for us - we really need to support
> communications out to other nodes on the network that we can't count on using
> vlan.  
>   
Perhaps I am misunderstand but the macvlan is just an "eth aliased" 
interface, so you should but able to communicate with the outside world 
and keep the same performances as the physical device, no ? The only 
drawback with the macvlan is you can not communicate on the same host 
between different namespaces. We did some benchmark last year wih the 
macvlan and we got very good results.
