From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: IO controller Mini-Summit 2009
Date: Thu, 15 Oct 2009 11:35:36 +0900 (JST)
Message-ID: <20091015.113536.232748879.ryov__27069.0420679331$1255574198$gmane$org@valinux.co.jp>
References: <20091014175521.GG3528@redhat.com> <4AD66F28.9030607@oss.ntt.co.jp>
	<4AD67DFB.60402@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AD67DFB.60402-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: yoshikawa.takuya-gVGce1chcLdL9jVzuh4AOg@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, takebe_akio-+CUm20s59erQFUHtdCDX3A@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Yoshikawa-san and all,

Takuya Yoshikawa <yoshikawa.takuya-gVGce1chcLdL9jVzuh4AOg@public.gmane.org> wrote:
> Hi all,
> =

> As Fernando said below, I will be glad if I can help you by taking
> notes of the mini summit. I would also be glad if someone helps me
> take notes.

It is very helpful, thank you very much.

> Tsuruta-san, thank you for summarizing the topics. It looks good!
> The only thing I am worrying about is whether we can summarize our
> discussions for 5-6 minutes of presentation.

I would like to do what little I can to help it.
And if you permit, I would like to publish the meeting miniutes and
the presentation slides on the mini-summit web site.
 =

> I would be happy if we all have it in mind that we can send our
> message to maintainers, including Ted Tso, by sending our summary.
> So before starting the discussion, how about taking some time to
> talk about which topic we want to include in the summary.

I think it is a good idea to talk about it at the start.

> IMHO,
>  >>> - The place where IO controller should be implemented
> is the most important, basic, topic, and other things should be
> summarized so as to explain why we think the place, e.g. block layer,
> VFS layer, common layer, is better for implementing io controllers.
> =

> It would also be better if we can answer to the comments we have
> already received from maintainers, e.g. Andrew, Jens.

I would like to do so, too.

Thanks,
Ryo Tsuruta

> Thanks,
> Takuya Yoshikawa
> =

> =

> =

> =

> Fernando Luis V=E1zquez Cao wrote:
> > Hi Vivek,
> > Thank you for CCing me.
> > I just wanted to let you know that Ted Tso was kind enough to let
> > us give a readout for the mini-summit at the kernel summit.
> > There will be other mini-summits sharing 50 minutes so we need to
> > keep each mini-summit readout to 5-6 minutes of presentation and
> > 4-5 minutes of questions/discussions.
> > Yoshikawa-san and myself were planning to take notes of the
> > mini-summit, but it would be great if you could share yours.  The
> > idea is to use those to prepare a brief mini-summit report (4-5
> > slides) that we can show at the kernel summit.
> > Later in the day, after the mini-summit, we would be sending a
> > draft version of the slides to the relevant mailing lists for you
> > to review. Since the mini-summit readouts will take place on
> > Monday I would appreciate it if you could comment on them before
> > Sunday night the latest.
> > Thanks,
> > Fernando
> > Vivek Goyal wrote:
> >> On Wed, Oct 14, 2009 at 09:24:44PM +0900, Ryo Tsuruta wrote:
> >>> Hello,
> >>>
> >>
> >> Hi Ryo,
> >>
> >> CCing people who are planning to attend the mini summit either in pers=
on
> >> or phone. (As per your list on io mini summit wiki page). Not sure if
> >> everybody is scanning mailing list for update on mini summit.
> >>
> >> I am checking out wiki page for more information like Venue. It says t=
he
> >> venue is linux foundation office Japan. Hopefully there is no change in
> >> that information.
> >>
> >> What are the conference call details for the people who might want to =
join
> >> in over phone? Could not find those. Are you yet to post these?
> >>
> >> Thanks
> >> Vivek
> >>
> >>> I have summarized the topics for the IO controller mini-summit and
> >>> written the ideas seen in the mailing list.
> >>>
> >>> - The place where IO controller should be implemented
> >>>   - Block layer in conjunction with the IO scheduler
> >>>   - Common layer right above the IO scheduler
> >>>   - CFQ enhancement.
> >>>   - Both block and common layer, users can select whichever controller
> >>>     they want.
> >>>   - VFS layer
> >>>
> >>> - What kind of bandwidth control policies are needed?
> >>>   - Proportional weight
> >>>   - Enforcing upper limit
> >>>   - Minimum bandwidth guarantee
> >>>
> >>> - How to handle buffered writes?
> >>>   - Add dirt-ratio in the memory controller
> >>>   - Add bufferred-write-cgroup to track buffered writebacks
> >>>   - A per group per bdi pdflush threads
> >>>
> >>> - Who should be charged for swap activity?
> >>>   - who requests a page.
> >>>   - who has a page.
> >>>   - All swap activities are charged to the root group.
> >>>
> >>> And I would also like to discuss about the followings.
> >>>
> >>> - Extensions of struct bio
> >>>   - Make a bio point to the io_context of a process which creates the
> >>>     I/O request. This allows to pass the IO scheduling class and
> >>>     priority information to IO controller even if the IO is submitted
> >>>     by another process which does not create the request, such as a
> >>>     worker thread.
> >>>   - Add a new flag to struct bio to identify the bio as urgent. This
> >>>     gives IO controller a chance to handle the bio as high
> >>>     priority. This flag should be set if the bio is created for the
> >>>     page-out operation.
> >>> - Common test methods to verify the functionality of IO controller.
> >>>
> >>> Please give me comments and suggestions. I may be missing or
> >>> misunderstanding something.
> >>>
> >>> Thanks,
> >>> Ryo Tsuruta
> >>> -- To unsubscribe from this list: send the line "unsubscribe linux-ke=
rnel" in
> >>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>> Please read the FAQ at  http://www.tux.org/lkml/
> > =

> =

> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
