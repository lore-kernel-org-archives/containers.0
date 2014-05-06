From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] namespaces: log namespaces per task
Date: Tue, 6 May 2014 17:15:30 -0400
Message-ID: <20140506211530.GB15100@madcap2.tricolour.ca>
References: <cover.1398176489.git.rgb@redhat.com>
	<20140501223212.GA25669@mail.hallyn.com>
	<20140502142851.GC24111@madcap2.tricolour.ca>
	<5367587B.20801@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5367587B.20801-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On 14/05/05, Nicolas Dichtel wrote:
> Le 02/05/2014 16:28, Richard Guy Briggs a ?crit :
> >On 14/05/02, Serge E. Hallyn wrote:
> >>Quoting Richard Guy Briggs (rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> >>>I saw no replies to my questions when I replied a year after Aris' posting, so
> >>>I don't know if it was ignored or got lost in stale threads:
> >>>         https://www.redhat.com/archives/linux-audit/2013-March/msg00020.html
> >>>         https://www.redhat.com/archives/linux-audit/2013-March/msg00033.html
> >>>	(https://lists.linux-foundation.org/pipermail/containers/2013-March/032063.html)
> >>>         https://www.redhat.com/archives/linux-audit/2014-January/msg00180.html
> >>>
> >>>I've tried to answer a number of questions that were raised in that thread.
> >>>
> >>>The goal is not quite identical to Aris' patchset.
> >>>
> >>>The purpose is to track namespaces in use by logged processes from the
> >>>perspective of init_*_ns.  The first patch defines a function to list them.
> >>>The second patch provides an example of usage for audit_log_task_info() which
> >>>is used by syscall audits, among others.  audit_log_task() and
> >>>audit_common_recv_message() would be other potential use cases.
> >>>
> >>>Use a serial number per namespace (unique across one boot of one kernel)
> >>>instead of the inode number (which is claimed to have had the right to change
> >>>reserved and is not necessarily unique if there is more than one proc fs).  It
> >>>could be argued that the inode numbers have now become a defacto interface and
> >>>can't change now, but I'm proposing this approach to see if this helps address
> >>>some of the objections to the earlier patchset.
> >>>
> >>>There could also have messages added to track the creation and the destruction
> >>>of namespaces, listing the parent for hierarchical namespaces such as pidns,
> >>>userns, and listing other ids for non-hierarchical namespaces, as well as other
> >>>information to help identify a namespace.
> >>>
> >>>There has been some progress made for audit in net namespaces and pid
> >>>namespaces since this previous thread.  net namespaces are now served as peers
> >>>by one auditd in the init_net namespace with processes in a non-init_net
> >>>namespace being able to write records if they are in the init_user_ns and have
> >>>CAP_AUDIT_WRITE.  Processes in a non-init_pid_ns can now similarly write
> >>>records.  As for CAP_AUDIT_READ, I just posted a patchset to check capabilities
> >>>of userspace processes that try to join netlink broadcast groups.
> >>>
> >>>
> >>>Questions:
> >>>Is there a way to link serial numbers of namespaces involved in migration of a
> >>>container to another kernel?  (I had a brief look at CRIU.)  Is there a unique
> >>>identifier for each running instance of a kernel?  Or at least some identifier
> >>>within the container migration realm?
> >>
> >>Eric Biederman has always been adamantly opposed to adding new namespaces
> >>of namespaces, so the fact that you're asking this question concerns me.
> >
> >I have seen that position and I don't fully understand the justification
> >for it other than added complexity.
> Just FYI, have you seen this thread:
> http://thread.gmane.org/gmane.linux.network/286572/
> 
> There is some explanations/examples about this topic.

Thanks for that reference.  I read it through, but will need to do so
again to get it to sink in.

> Nicolas

- RGB

--
Richard Guy Briggs <rbriggs-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
