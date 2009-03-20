From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] c/r: Add UTS support (v4)
Date: Fri, 20 Mar 2009 14:39:48 -0700
Message-ID: <1237585188.8286.319.camel@nimitz>
References: <1237402291-28812-1-git-send-email-danms@us.ibm.com>
	<49C2C686.2060806@cs.columbia.edu>
	<871vstdtn1.fsf@caffeine.danplanet.com>
	<49C2CDFA.4010907@cs.columbia.edu> <49C2D183.8040905@cs.columbia.edu>
	<20090320181043.GB8380@us.ibm.com> <49C3EFAF.9030706@cs.columbia.edu>
	<1237579196.8286.239.camel@nimitz> <49C4011C.1050707@cs.columbia.edu>
	<1237582825.8286.285.camel@nimitz> <49C40A23.6080708@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C40A23.6080708-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2009-03-20 at 17:26 -0400, Oren Laadan wrote:
> Dave Hansen wrote:
> > On Fri, 2009-03-20 at 16:48 -0400, Oren Laadan wrote:
> >> Does that scale well with many (1000's) of tasks ?
> >>
> >> (The motivation to expose 'nsproxy_objref' to user space was to allow
> >> user-space to decide on a sequence of clones/unshared that will create
> >> an equivalent process tree with space-efficient nsproxy's).
> > 
> > OK, so you're saying that there's no way for userspace to tell that a
> > set of tasks share an nsproxy other than exporting that nsproxy?
> 
> I don't think so. Maybe the namespaces people know better.

Please go look at the code.

Two processes share an nsproxy (or *can* share an nsproxy) when all of
the namespace pointers are the same.  After allocation and
initialization, we basically don't ever write to the nsproxy.  We just
hook it into a task and run with it.

If anything ever unshares one of the nsproxy namespaces, before writing
to it we *first* create a new nsproxy which is a copy of the old one.

We basically open-code copy-on-write semantics for the nsproxy.

This means that it is safe for any two tasks that share all of the
pointers in the nsproxy to share an nsproxy itself.

-- Dave
