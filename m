From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Thu, 12 Mar 2009 17:48:20 -0500
Message-ID: <20090312224820.GA12723@hallyn.com>
References: <1236880612-15316-1-git-send-email-danms@us.ibm.com>
	<20090312162954.4a4b8e00@thinkcentre.lan>
	<87fxhipfrh.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87fxhipfrh.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> NL> I'd like there to be some discussion about this, because namespace
> NL> creation seems like a significant addition to the semantics of
> NL> restart as I understand it.
> 
> Indeed.
> 
> NL> Is namespace creation during restart unavoidable, or merely
> NL> desirable?  Is there a case for requiring the user to provide a
> NL> suitable namespace environment before attempting restart?
> 
> Information about the namespaces has to be saved at checkpoint time no
> matter what, right?  I guess I don't see any compelling reason to not
> have the restart operation replicate the environment of the original
> process.  Otherwise we require userspace to read and interpret the
> checkpoint stream and selectively feed the bits that the kernel is
> responsible for to the kernel and process the rest itself (or have the
> kernel ignore those records).

Well we haven't yet settled the Oren-vs-Alexey argument of who sets
up the new process tree.  Oren would have userspace parse the checkpoint
file, do a bunch of clones to recreate the process tree, then have each
task call sys_restart().  Alexey would have one task call sys_restart()
where the system call then recreates the process tree.

You seem to be doing half of each :)  I think if we go with Oren's
route then we should use CLONE_NEWPID etc flags from userspace to set
up the proper relationships.  If we go with Alexey's, then the kernel
can just hand-create the nsproxies somewhat the way you are doing using
copy_namespaces().

> What's the argument for depending on userspace to set this up?

Well it forces restart to go through the established userspace API's
when creating resources (in this case, tasks and namespaces) which
means any existing security guarantees are leveraged.

If we go with your patch, we suddenly have to worry about whether
restart is a way to get around the CAP_SYS_ADMIN requirements for
cloning a new namespace.  Just as an example.

-serge
