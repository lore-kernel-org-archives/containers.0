From: jacob pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [RFC PATCH 1/2] cgroup: add per cgroup timer_slack_ns
Date: Thu, 2 Dec 2010 14:06:50 -0800
Message-ID: <20101202140650.1bc71e53__28300.054689362$1291327712$gmane$org@jacob-laptop>
References: <1291230012-9536-1-git-send-email-jacob.jun.pan@linux.intel.com>
	<1291230012-9536-2-git-send-email-jacob.jun.pan@linux.intel.com>
	<AANLkTi=1uv-+Y5t85tyHKk91nJyAKNg5V4Fk2HTJ+ASS@mail.gmail.com>
	<20101202124559.0a7128de@jacob-laptop>
	<AANLkTimRrSjJDAxS2Pe5bfMbR=nuV6WQiJdnawSb_kZd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTimRrSjJDAxS2Pe5bfMbR=nuV6WQiJdnawSb_kZd-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, container cgroup <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Arjan-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2 Dec 2010 12:52:36 -0800
Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> On Thu, Dec 2, 2010 at 12:45 PM, jacob pan
> <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:
> >
> > I guess timer_slack_ns alone cannot qualify for a new subsystem,
> 
> I think that it's providing a sufficiently different control from
> existing subsystems that making it a separate subsystem is reasonable.
> The cpuset subsystem definitely doesn't sound like the right place,
> since it's more dealing with numa isolation/policy. The cpu subsystem
> could be, since it also deals with scheduling stuff.
> 
> Paul
thanks for the pointer. let me try to add a new subsystem. call
it timer? perhaps will have future expansion.
