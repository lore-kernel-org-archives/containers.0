From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Net containers config and usage
Date: Thu, 15 Jan 2009 20:38:23 -0800
Message-ID: <m1ocy7vpa8.fsf@frodo.ebiederm.org>
References: <20090113214747.GA23742@versecorp.net>
	<1231887220.6398.73.camel@groeck-laptop> <496DA755.1040001@free.fr>
	<20090114172739.GA13581@versecorp.net> <496E23DA.9080402@free.fr>
	<20090114192633.GA8572@us.ibm.com>
	<20090114193944.GA14129@versecorp.net> <496E42D6.2080306@free.fr>
	<20090115215900.GA30607@versecorp.net> <496FB6F7.9080906@free.fr>
	<20090115232013.GA9722@versecorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090115232013.GA9722-SqNQQPNds68nxqbYAscKCQ@public.gmane.org> (Chris R. Jones's message
	of "Thu, 15 Jan 2009 15:20:13 -0800")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Chris R. Jones" <chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org>
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

"Chris R. Jones" <chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org> writes:

> On Thu, Jan 15, 2009 at 11:21:43PM +0100, Daniel Lezcano wrote:
>> chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org wrote:
>> >>Did you tried with the macvlan ?
>> >>    
>> >
>> >I just tried it - and it does work - I can move the vlan interfaces into 
>> >the
>> >namespace.   But that's not a solution for us - we really need to support
>> >communications out to other nodes on the network that we can't count on 
>> >using
>> >vlan.  
>> >  
>> Perhaps I am misunderstand but the macvlan is just an "eth aliased" 
>> interface, so you should but able to communicate with the outside world 
>> and keep the same performances as the physical device, no ? The only 
>> drawback with the macvlan is you can not communicate on the same host 
>> between different namespaces. 

And that drawback (when all the macvlan are off of the same network device is
actually a bug).

>We did some benchmark last year wih the 
>> macvlan and we got very good results.
>
> Oh great, I confused the macvlan support with 802.1q vlan interfaces 
> (as added through vconfig).  macvlan does look very promising - I was able 
> to create a macvlan interface and assign it to my namespace - looks pretty good!

Good to hear you have a solution.  Putting physical hardware devices in network
namespaces is definitely on the todo.  But it looks to be a while before we get
all of the details sorted out.

Eric
