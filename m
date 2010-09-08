From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: C/R: File substitution at restart
Date: Wed, 8 Sep 2010 17:49:27 -0500
Message-ID: <20100908224927.GA13496@hallyn.com>
References: <4C875F6E.2030004@kerlabs.com> <20100908130931.GA11161@hallyn.com>
	<20100908175648.GA12281@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100908175648.GA12281-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Matthieu =?iso-8859-1?Q?Fertr=E9?= <matthieu.fertre-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>, Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> Serge Hallyn [serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org] wrote:
> | Quoting Matthieu Fertr=E9 (matthieu.fertre-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org):
> | > Hi,
> | > =

> | > Here is a proposal for a C/R related feature already developed in
> | > Kerrighed: file substitution at restart.
> | > =

> | > The goal of this mail is to start a discussion about adding such feat=
ure
> | > to Linux cr. Comments are welcome!
> | =

> | Yup, AFAIK metacluster and zap do this too.  I don't think there is
> | any question about whether we want to support this, but rather
> | what the user-kernel API should look like.  Perhaps the easiest
> | "API" is to have the userspace program rewrite the checkpoint image,
> | but that probably isn't quite as simple as just substituting #s in
> | the image, bc we'll have to also find the place where the source of
> | the original fd was specified and tweak that.
> | =

> | I assume this is one of the things Oren would have 'cradvise()'
> | do, and at this point that sounds nice to me - might be worth
> | seeing how the community reacts.  Sentiments on such things change,
> | after all.
> =

> Yes, I had the same question about the kernel API. cradvise() would be
> one option, but am not too clear on the details. For each process in
> the checkpoint image that we want to substitute one or more fds,
> do we call cradvise() *before* the call to sys_restart() ? This would

No, I would rather think that we follow the Kerrighed example,
and specify a checkpoint-wide id for the fd (the objhash id i
guess).  The first cr_advise() starts to create a restart context,
which finally gets used at sys_restart by the coordinator (and of
course all subsequent tasks).

> require the kernel to save these substitution pairs in memory until
> the following sys_restart() right ?
> =

> Passing in a list of fd-substition pairs to sys_restart() might be one
> option, but would require modifying the sys_restart() API.
> =

> Sukadev
