From: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [RFC] Transactional CGroup task attachment
Date: Mon, 14 Jul 2008 12:56:49 +0200
Message-ID: <1216033009.12595.25.camel@twins>
References: <6599ad830807092346j1fdb2ef9l2ca2b52e2e68096a@mail.gmail.com>
	<1215821034.5456.357.camel@localhost.localdomain>
	<6599ad830807111718ye005349yaa31e729c233474f@mail.gmail.com>
	<1215823694.5456.382.camel@localhost.localdomain>
	<6599ad830807111849q7aaf8226tba15193fa23f9531@mail.gmail.com>
	<1215828216.5456.409.camel@localhost.localdomain>
	<6599ad830807111909j4d777735ree2ee17dfcdda853@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830807111909j4d777735ree2ee17dfcdda853-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Daisuke Miyakawa =?UTF-8?Q?=28=E5=AE=AE=E5=B7=9D_=E5=A4=A7=E8=BC=94=29?= <dmiyakawa-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2008-07-11 at 19:09 -0700, Paul Menage wrote:
> On Fri, Jul 11, 2008 at 7:03 PM, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> >
> >        True, though I don't think it's as simple as just enabling lockdep. My
> > understanding is you won't be able to determine if locks could ever be
> > taken out of order unless all of the cgroup systems are enabled and they
> > are all in the same cgroup hierarchy.
> 
> I wonder how hard it would be to extend lockdep to give a "signature"
> of locking operations from point A to point B? Then you could just
> compare a new subsystem with all existing subsystems without actually
> running with it.

something like: http://lkml.org/lkml/2008/6/22/308 ?
