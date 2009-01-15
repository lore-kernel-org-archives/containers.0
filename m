From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 0/2] cr: Introduce s390x checkpoint/restart code
Date: Thu, 15 Jan 2009 16:25:39 -0600
Message-ID: <20090115222539.GA24296@us.ibm.com>
References: <20090115050523.GA10415@us.ibm.com>
	<1232012395.30152.13.camel@localhost>
	<496F082C.3020008@cs.columbia.edu>
	<1232014244.30152.19.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1232014244.30152.19.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Martin Schwidefsky (schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org):
> What is left are the pgstes tables. After you forked the new process
> that is used to restart a KVM enabled process you need to call
> s390_enable_sie(), preferably before you recreate the VMAs.

So, let's say we're checkpointing 3 tasks in a s390-kvm.
Now we restart them outside of kvm.  Some process will
fork(), exec() some restart program, which will in turn
fork() twice, then each of those programs will call
sys_restart(), read the info pertaining to the checkpoint
task they are to re-create, and set themselves up.

Should the s390_enable_sie() then not be correctly set
by the system automatically?  So whether or not I'm
restarting in kvm, the kvm_arch_create_vm() for s390
will have been called?

Or do I misunderstand?

thanks,
-serge
