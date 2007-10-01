From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 4/5] Setup the control group
Date: Mon, 01 Oct 2007 21:23:54 +0530
Message-ID: <47011812.2010406@linux.vnet.ibm.com>
References: <46F91841.9070708@openvz.org> <46F91A1E.2060303@openvz.org>
	<4700FAAC.2050004@linux.vnet.ibm.com> <4700FB72.5070409@openvz.org>
	<4701013A.3010307@linux.vnet.ibm.com> <47010169.5040102@openvz.org>
	<47010276.8060802@linux.vnet.ibm.com>
	<6599ad830710010850q660d042av9fa5a461d3c3e445@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830710010850q660d042av9fa5a461d3c3e445-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On 10/1/07, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>> Yes, we need to do that. Paul Menage wanted to pull in resource counters
>> into cgroups.
> 
> No, that's not what I wanted - I just wanted to try to cut down the
> boilerplate required to use resource counters. Ideally it would be as
> simple as including a call to some function such as
> "add_res_counter(...)" which would deal with setting up all the cgroup
> control files, provide handlers, etc. This also helps to keep all the
> APIs consistent.
> 
> See the patch that I sent last week entitled "Simplify memory
> controller and resource counter I/O" for a first step in that
> direction.
> 

OK. I'll take a closer look

>> Also, I'd like to be able to share res_counters between
>> container groups or at-least support a hierarchy.
> 
> A hierarchy sounds like a good idea.
> 
> For the sharing, there are two approaches - any subsystem that wants
> sharing has to implement it itself, or else implement sharing at the
> control groups level and make it (mostly) transparent to the
> subsystems. I think I prefer the latter and have been playing with
> some ways to do this.
> 

Excellent, I prefer the later as well, but it would mean overheads
for controllers not using the hierarchy. If we can come up with
a design such that parents<->children can effectively share resources,
track them and do so recursively, that would be really nice.

> Paul


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
