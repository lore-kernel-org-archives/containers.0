From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add UTS support (v4)
Date: Thu, 19 Mar 2009 15:39:46 -0700
Message-ID: <871vstdtn1.fsf@caffeine.danplanet.com>
References: <1237402291-28812-1-git-send-email-danms@us.ibm.com>
	<49C2C686.2060806@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C2C686.2060806-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Thu, 19 Mar 2009 18:26:14 -0400")
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

OL> So what happens in the following scenario:

OL> * task A is the container init(1)
OL> * A calls fork() to create task B
OL> * B calls unshare(CLONE_NEWUTS)
OL> * B calls clone(CLONE_PARENT) to create task C

In the previous version of the patch, I failed the checkpoint if this
was the case by making sure that all tasks in the set had the same
nsproxy.  You said in IRC that this was already done elsewhere in the
infrastructure, but now that I look I don't see that anywhere.

The check I had was in response to Daniel's comments about avoiding
the situation for the time being by making sure that all the tasks had
the same set of namespaces (i.e. the same nsproxy at the time of
checkpoint).

OL> Two approaches to solve this are:

OL> a) Identify, in mktree, that this was the case, and impose an
OL> order on the forks/clones to recreate the same dependency (an
OL> algorithm for this is described in [1])

OL> b) Do it in the kernel: for each nsproxy (identified by an objref)
OL> the first task that has it will create it during restart, in or
OL> out of the kernel, and the next task will simply attach to the
OL> existing one that will be deposited in the objhash.

I think that prior discussion led to the conclusion that simplicity
wins for the moment, but if you want to solve it now I can cook up
some changes.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
