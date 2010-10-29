From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 0/5][v5][cr] Checkpoint/restart file locks
Date: Fri, 29 Oct 2010 11:35:07 -0700
Message-ID: <20101029183507.GA6726__11884.5520228662$1288376904$gmane$org@us.ibm.com>
References: <1288333001-28838-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<AANLkTiktKVuAtjPaHT9d+7ATpKn+jMonFYzeEmd85L3o@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTiktKVuAtjPaHT9d+7ATpKn+jMonFYzeEmd85L3o-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lin Ming <lin-7mNXGst3two@public.gmane.org>
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Lin Ming [lin-7mNXGst3two@public.gmane.org] wrote:
| Hi,
| 
| Which tree are these patches against?
| 
| I can't apply them neither to Linus tree(18cb657c) nor
| vfs-2.6.git/for-linus branch(a4cdbd8b).

These apply to the checkpoint/restart tree:

	git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git

They need the checkpoint/restart infrastructure which is not in the main
line kernel yet. We have been using the [cr] prefix to identify these
patches, but will add a pointer to the above tree in the future.

Thanks,

Sukadev
