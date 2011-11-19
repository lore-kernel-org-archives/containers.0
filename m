From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 6/6] protect cap_netlink_recv from user namespaces
Date: Sat, 19 Nov 2011 01:10:29 -0800
Message-ID: <m11ut41nqy.fsf@fess.ebiederm.org>
References: <1320445482-8459-1-git-send-email-serge@hallyn.com>
	<1320445482-8459-7-git-send-email-serge@hallyn.com>
	<1320694510.10093.23.camel@localhost>
	<20111108032902.GA29433@hallyn.com>
	<1320848342.10093.57.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1320848342.10093.57.camel@localhost> (Eric Paris's message of
	"Wed, 09 Nov 2011 09:19:02 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: richard-/L3Ra7n9ekc@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Tue, 2011-11-08 at 03:29 +0000, Serge E. Hallyn wrote:
>> Quoting Eric Paris (eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
>
>> But, regardless, your point is valid in that I'm not tightening down as
>> much as I could.  So how about I don't change the security_netlink_recv()
>> and callers yet, and instead I change cap_netlink_recv() to do:
>> 
>> 	if (!IN_ROOT_USER_NS && !cap_raised(current_cap(), cap))
>
> Actually better thought.  Remove the LSM hook altogether and just use
> capable() in the callers.  This hook, being used this way, was
> introduced in c7bdb545 back when we took the effective perms from the
> skb.  We don't use the skb any more since netlink is synchronous.  This
> is functionally equivalent except the capabilities code checks against
> the init_user_ns (something we want) and it will now set PF_PRIV (which
> also seems like a good thing) Something like:
>
> security: remove the security_netlink_recv hook as it is equivalent to capable()
>     
> Once upon a time netlink was not sync and we had to get the effective
> capabilities from the skb that was being received.  Today we instead get
> the capabilities from the current task.  This has rendered the entire
> purpose of the hook moot as it is now functionally equivalent to the
> capable() call.
>
> Signed-off-by: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Darn.  I missed this one went it went past the first time.  Let's do
this.

As Serge pointed out checking against the user namespace of the network
namespace happens to be safe because the subsystems that are brittle
really have problems don't support multiple network namespaces.

Still I like the idea of erring on the conservative side here and
making everything safe.  We can open relax the restrictions later
by using ns_capable.  I want to get to a point where it is safe
for an unprivileged user to create their own user namespace,
and most of that is just getting the capable calls correct.

Eric
