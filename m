From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] audit: provide namespace information in user
	originated records
Date: Wed, 20 Mar 2013 13:49:52 -0500
Message-ID: <20130320184952.GA16488@sergelap>
References: <1363619405-6419-1-git-send-email-arozansk@redhat.com>
	<877gl48iaz.fsf@xmission.com> <20130319122408.GC20187@redhat.com>
	<874ng7gcst.fsf@xmission.com> <20130320154503.GF20187@redhat.com>
	<20130320183652.GA13839@sergelap>
	<1363804924.2333.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1363804924.2333.12.camel@localhost>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric Paris (eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> On Wed, 2013-03-20 at 13:36 -0500, Serge Hallyn wrote:
> > Quoting Aristeu Rozanski (arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> > > This is a bit fuzzy to me, perhaps due I'm not fully understanding
> > > userns implementation yet, so bear with me:
> > > I thought of changing so userns would not grant CAP_AUDIT_WRITE and
> > > CAP_AUDIT_CONTROL unless the process already has it (i.e. it'd require
> > 
> > Seems like CAP_AUDIT_WRITE should be targeted against the
> > skb->netns->userns.  Then CAP_AUDIT_WRITE can be treated like any other
> > capability.  Last I knew (long time ago) you had to be in init_user_ns
> > to talk audit, but that's ok - this would just do the right thing in
> > any case.
> 
> kauditd should be considered as existing in the init user namespace.  So
> I'd think we'd want to check if the process had CAP_AUDIT_WRITE in the
> init user namespace and if so, allow it to send messages.  Who care what
> *ns the process exists in.  If it has it in the init namespace, go
> ahead.  Thus the process that created the container would need
> CAP_AUDIT_WRITE in the init namespace for this to all work, right?

Yes.  What I was suggesting is intended to work if that situation ever
changes.  But I have zero complaints about doing it as you say, as I
doubt it ever will/ought to change.

That basically means CAP_AUDIT_WRITE would be worthless in a non-init
userns.  That's fine - at least the rules would be consistent.

> /me also gets so confused about what caps mean in the userns world.

If the resource in question (like a network interface) belongs to a
namespace (netns) created by the userns in which the caller has the caps
in question, then privilege is granted.

Otherwise, not.

What you're saying above about CAP_AUDIT_WRITE is exactly right (for
how audit works right now).

> (/me has larger issues with the ns concept as a whole, but that boat
> sailed years and years ago)

-serge
