From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][-mm] [0/2] Basic stats for cgroups V2
Date: Tue, 8 Apr 2008 07:52:16 -0700
Message-ID: <6599ad830804080752w15882801oaa4fb4b661e7302a@mail.gmail.com>
References: <200804052339.42474.balajirrao@gmail.com>
	<6599ad830804080036h5496e3bdv9ac2dedf0f04f9bc@mail.gmail.com>
	<200804081919.14601.balajirrao@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200804081919.14601.balajirrao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balaji Rao <balajirrao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Apr 8, 2008 at 6:49 AM, Balaji Rao <balajirrao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
>  We are also looking at a generic framework in cgroups that would delegate the
>  job of handling statistics to the cgroup framework itself. This would avoid
>  code duplication across various controllers.

Yes, avoiding code duplication is good.

On thing - when you say "statistics" do you mean all statistics (i.e.
all values that can be read from control files) or specifically
arrays/maps of values in specific control files? I'm using it to mean
the former, but you appear to be mostly referring to stats maps such
as "memory.stat" or "cpu.stat".

Paul
