From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] audit: provide namespace information in user
	originated records
Date: Wed, 20 Mar 2013 13:36:52 -0500
Message-ID: <20130320183652.GA13839@sergelap>
References: <1363619405-6419-1-git-send-email-arozansk@redhat.com>
	<877gl48iaz.fsf@xmission.com> <20130319122408.GC20187@redhat.com>
	<874ng7gcst.fsf@xmission.com> <20130320154503.GF20187@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130320154503.GF20187-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Aristeu Rozanski (arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> This is a bit fuzzy to me, perhaps due I'm not fully understanding
> userns implementation yet, so bear with me:
> I thought of changing so userns would not grant CAP_AUDIT_WRITE and
> CAP_AUDIT_CONTROL unless the process already has it (i.e. it'd require

Seems like CAP_AUDIT_WRITE should be targeted against the
skb->netns->userns.  Then CAP_AUDIT_WRITE can be treated like any other
capability.  Last I knew (long time ago) you had to be in init_user_ns
to talk audit, but that's ok - this would just do the right thing in
any case.

-serge
