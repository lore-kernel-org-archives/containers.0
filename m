From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4][cr]: Define __f_setown_uid()
Date: Wed, 12 May 2010 10:05:10 -0700
Message-ID: <20100512170510.GB11144__37682.586714118$1273683628$gmane$org@us.ibm.com>
References: <1273617500-13653-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1273617500-13653-3-git-send-email-sukadev@linux.vnet.ibm.com>
	<20100512140741.GF10452@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100512140741.GF10452-6jwH94ZQLHl74goWV3ctuw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Matthew Wilcox [matthew-Ztpu424NOJ8@public.gmane.org] wrote:
| On Tue, May 11, 2010 at 03:38:18PM -0700, Sukadev Bhattiprolu wrote:
| > __f_setown_uid() is same as __f_setown(), except that instead of assuming the
| > uid and euid of current process, it expects them to be passed in as parameters.
| > 
| > This interface will be useful when checkpointing and restarting an application
| > that has a 'file owner' specified for any of the application's open files.
| > The uid, euid of the process setting up the owner is saved in the checkpoint
| > image. When the application is restarted, the save uid and euid values are
| > restored.
| 
| There are only four callers of __f_setown in the kernel.  I'd rather see
| __f_setown converted to take the arguments directly.

Ok.

Sukadev
