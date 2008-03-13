From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 4/4] PID: use the target ID specified in procfs
Date: Thu, 13 Mar 2008 19:24:10 -0400
Message-ID: <47D9B79A.80201@cs.columbia.edu>
References: <20080310135054.312992000@bull.net>	<20080310135209.769712000@bull.net>
	<47D67557.7080506@openvz.org>	<47D6A52D.6030701@bull.net>
	<47D6A741.9080708@openvz.org>	<20080311164725.GA12918@sergelap.austin.ibm.com>	<47D6B990.4080400@openvz.org>	<20080311175328.GA14171@sergelap.austin.ibm.com>	<m1zlt3yarj.fsf@ebiederm.dsl.xmission.com>
	<47D904E4.4000208@bull.net>	<m1r6eewmj2.fsf@ebiederm.dsl.xmission.com>	<47D987FE.9040909@cs.columbia.edu>
	<m163vqw74n.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m163vqw74n.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org



Eric W. Biederman wrote:
> Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:
> 
>>>> I'm sorry but I'm pretty new in this domain, so I don't see what are the
>>>> namespaces where setting (or pre-setting) the id would be a problem?
>>> pids to some extent as people use them in all kinds of files.  Being
>>> able to force the pid of another process could make a hard to trigger
>>> security hole with file permissions absolutely trivial to hit.
>> Since the intent of this mechanism is to allow ckpt/restart, it makes
>> sense to only allow this operation during restart. For example, in zap,
>> containers have a state, e.g. running, stopped, ckpt, restart, and this
>> is only possible in restart state; Furthermore, a container can only be
>> put in restart state at creation time, and only by root. Of course, you
>> should only trust that as much as you trust the root  :O
> 
> Yes and thanks.
> 
> The notion of the state of a container makes a lot of sense (even if
> we never implement explicit state bits).

I found it extremely helpful in managing containers (pods) in zap. There
are three more states, actually: stopping, reviving and dead. It is like
extending the notion of process state into their collective representation
which is the container. In fact, restricting certain operations to specific
states was instrumental in eliminating a myriad of potential races in the
implementation.

I believe this belongs to the ever-pending ckpt/restart discussion :)

Oren.

> 
> Eric
