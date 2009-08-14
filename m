From: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH] flexible array implementation v4
Date: Fri, 14 Aug 2009 10:56:18 -0700
Message-ID: <e9c3a7c20908141056o32ce1204k6751b43271aa88ab__2864.76223632253$1250272653$gmane$org@mail.gmail.com>
References: <20090723152647.D9391722@kernel>
	<20090724163814.08c7eee3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090724163814.08c7eee3.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jul 24, 2009 at 4:38 PM, Andrew Morton<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> w=
rote:
> On Thu, 23 Jul 2009 08:26:47 -0700
> Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>
>> =A0linux-2.6.git-dave/include/linux/flex_array.h | =A0 46 ++++
>> =A0linux-2.6.git-dave/lib/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02
>> =A0linux-2.6.git-dave/lib/flex_array.c =A0 =A0 =A0 =A0 =A0 | =A0269 ++++=
++++++++++++++++++++++
>
> I haven't looked at this lately but I merged it.
>
> As it's obviously non-injurious, we could slip it into 2.6.31 for
> convenience's sake but without any callers that's just runtime bloat.
> So I guess we wait for some additional callers to come along and prove
> its worth.
>

I am considering using this for managing the descriptor ring in a
device driver, but I am concerned with the overhead of the divides.
Would it be acceptable to round the element size to the next
power-of-2 value so we can replace all the divides with shifts?

Thanks,
Dan
