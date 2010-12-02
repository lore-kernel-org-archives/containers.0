From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 1/2] cgroup: add per cgroup timer_slack_ns
Date: Thu, 2 Dec 2010 12:52:36 -0800
Message-ID: <AANLkTimRrSjJDAxS2Pe5bfMbR=nuV6WQiJdnawSb_kZd__28874.946505721$1291323308$gmane$org@mail.gmail.com>
References: <1291230012-9536-1-git-send-email-jacob.jun.pan@linux.intel.com>
	<1291230012-9536-2-git-send-email-jacob.jun.pan@linux.intel.com>
	<AANLkTi=1uv-+Y5t85tyHKk91nJyAKNg5V4Fk2HTJ+ASS@mail.gmail.com>
	<20101202124559.0a7128de@jacob-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101202124559.0a7128de@jacob-laptop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: jacob pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Cc: Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, container cgroup <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Dec 2, 2010 at 12:45 PM, jacob pan
<jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:
>
> I guess timer_slack_ns alone cannot qualify for a new subsystem,

I think that it's providing a sufficiently different control from
existing subsystems that making it a separate subsystem is reasonable.
The cpuset subsystem definitely doesn't sound like the right place,
since it's more dealing with numa isolation/policy. The cpu subsystem
could be, since it also deals with scheduling stuff.

Paul
