From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: unshare() pid ns
Date: Thu, 30 Aug 2007 07:19:40 -0700
Message-ID: <20070830141940.GA2025@us.ibm.com>
References: <20070830052928.GA27864@us.ibm.com> <46D67B8B.2000606@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46D67B8B.2000606-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelianov [xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org] wrote:
| sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
| >Pavel,
| >
| >unshare() of pid ns seems to fail with -EINVAL in 2.6.23-rc3-mm1.
| >I thought we supported it in the earlier patchsets.  I guess
| >I missed that in the review of recent patchsets.
| 
| I disabled unsharing of pid namespaces because it's almost
| impossible. Look - you have to reattach all the pids to the
| task with saving its ids as seen in previous namespaces.

Agree. Eric pointed that out early on.
| 
| >Did we remove/disable it on purpose ? I am not particular that we
| >support it though. Just want to make sure.
| >
| >Suka
| >
