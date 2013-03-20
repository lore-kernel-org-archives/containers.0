From: Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] audit: provide namespace information in user
	originated records
Date: Wed, 20 Mar 2013 15:17:28 -0400
Message-ID: <20130320191728.GH20187@redhat.com>
References: <1363619405-6419-1-git-send-email-arozansk@redhat.com>
	<877gl48iaz.fsf@xmission.com> <20130319122408.GC20187@redhat.com>
	<874ng7gcst.fsf@xmission.com> <20130320154503.GF20187@redhat.com>
	<20130320183652.GA13839@sergelap>
	<1363804924.2333.12.camel@localhost>
	<20130320184952.GA16488@sergelap>
	<1363806092.2333.19.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1363806092.2333.19.camel@localhost>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Mar 20, 2013 at 03:01:32PM -0400, Eric Paris wrote:
> [veering away from this particular patch]
> 
> We are also talking about adding a CAP_AUDIT_READ and sending messages
> via multicast on the audit socket.  The problem is I don't know how the
> audit socket could work in the network namespace world.  Right now
> kauditd has:
> 
> audit_sock = netlink_kernel_create(&init_net, NETLINK_AUDIT, &cfg);
> 
> So there won't ever be anything on the kernel side of the audit socket
> in a non-init network namespace.  Lets say that is fixed somehow (I
> assume it's possible?  something? magic pixies?) I think we'd somehow
> need to do the CAP_AUDIT_READ check against the user namespace
> associated with the network namespace in question?  But what messages
> should go to this userspace auditd?
> 
> Going to have to have audit namespaces to.  But only CAP_AUDIT_READ
> would make sense in the new audit namespace...

I guess that could be achieved by forcing creating a new network namespace at
the same time you create a new audit namespace. any new network
namespace created inside this new container would lose CAP_AUDIT_*.

-- 
Aristeu
