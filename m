From: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Wed, 18 Mar 2009 10:01:00 +0100
Message-ID: <49C0B84C.8010307@free.fr>
References: <1236880612-15316-1-git-send-email-danms@us.ibm.com>	<20090312162954.4a4b8e00@thinkcentre.lan>	<87fxhipfrh.fsf@caffeine.danplanet.com>	<20090312224820.GA12723@hallyn.com>	<87bps6pcyf.fsf@caffeine.danplanet.com>
	<49C0B069.6060300@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C0B069.6060300-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan wrote:
> 
> Dan Smith wrote:
>> SH> Well it forces restart to go through the established userspace
>> SH> API's when creating resources (in this case, tasks and namespaces)
>> SH> which means any existing security guarantees are leveraged.
>>
>> That's a very valid point.  However, it still seems unbalanced to make
>> checkpoint a completely in-kernel process and restart an odd mix of
>> the two with potentially more confusing semantics and requirements.
>>
> 
> There are other reasons to allow restart to be not fully symmetric
> with respect to checkpoint. For example, if you have a smart(er) user
> space application that wants to provide the restart some of the resources
> pre-constructed, allowing much flexibility (already requested by people)
> for the restart provdure (E.g., when doing distributed checkpoint, or
> when restarting a special device whose).

yes

the arguments you have for restart are also valid for checkpoint in a 
distributed checkpoint scenario. 

you want to be able to easily and rapidly abort the checkpoint of a job 
when one node (among thousands) fails for some reason. a batch manager 
would use a signal.  

you also want fine grain synchronization for network, when migrating only 
one node. 

We've had to solve the above issues on a large HPC project and there are 
plenty of other good reasons to have a mix of kernel and user space for 
restart and for checkpoint. 

C.
