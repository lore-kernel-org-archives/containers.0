From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: time virtualization
Date: Thu, 08 Oct 2009 10:51:31 -0700
Message-ID: <1255024291.9915.1543.camel@nimitz>
References: <1255004165.13367.153.camel@diese.inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1255004165.13367.153.camel-Vk9tpbkOzM4ZX7ca1aelMg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mathieu Lacage <mathieu.lacage-0GlwE4rufLnvuXihggDW+w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2009-10-08 at 14:16 +0200, Mathieu Lacage wrote:
> A not-too-old paper outlines a nice approach to emulation of networks:
> http://ds.informatik.rwth-aachen.de/members/weingaertner/publications/pdfs/hotmetrics08_shortened.pdf
> They modify XEN to allow different VMs to have a different view on time:
> each VM synchronizes with an external time source which can dynamically
> and arbitrarily slow down, speed up, or simply keep pace with the
> physical host clock, depending on what the user wants to achieve.

Honestly, it would take an absolute ton of work to break out all of the
kernel subsystems to look at time differently.  We'd even need
per-container jiffies and other scarier stuff like the NTP code.

This sounds to me like a perfect use case for hardware virtualization.
Long live Xen! :)

-- Dave
