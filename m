From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 5/6] cgroup, cpuset: don't use ss->pre_attach()
Date: Thu, 25 Aug 2011 11:06:26 +0200
Message-ID: <20110825090626.GE3286__38330.7380987846$1314263431$gmane$org@htj.dyndns.org>
References: <1314138000-2049-1-git-send-email-tj@kernel.org>
	<1314138000-2049-6-git-send-email-tj@kernel.org>
	<CALdu-PD5EbFJBRHf-iehPwb6vyJTYUTWZniihARFDZ7xRZ8_nQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALdu-PD5EbFJBRHf-iehPwb6vyJTYUTWZniihARFDZ7xRZ8_nQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: rjw-KKrjLPT3xs0@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Aug 25, 2011 at 01:53:57AM -0700, Paul Menage wrote:
> On Tue, Aug 23, 2011 at 3:19 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> > ->pre_attach() is supposed to be called before migration, which is
> > observed during process migration but task migration does it the other
> > way around. =A0The only ->pre_attach() user is cpuset which can do the
> > same operaitons in ->can_attach(). =A0Collapse cpuset_pre_attach() into
> > cpuset_can_attach().
> >
> > Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> =

> Acked-by: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
> =

> Code looks good, but I think that the some of the Documentation
> changes slipped in here by mistake.

Oops, indeed.  Will relocate them.

Thanks.

-- =

tejun
