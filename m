From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [BIG RFC] Filesystem-based checkpoint
Date: Thu, 30 Oct 2008 12:25:36 -0400
Message-ID: <4909E000.9070201@cs.columbia.edu>
References: <1225219047.12673.182.camel@nimitz>	<20081028205654.GA17487@us.ibm.com>
	<1225228229.12673.195.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1225228229.12673.195.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Tue, 2008-10-28 at 15:56 -0500, Serge E. Hallyn wrote:
>> If you like I can take a shot at whipping up the new mini-fs, though
>> I think you're having fun :)
> 
> There are a couple of concepts that just get easier once you start
> thinking of this as an entire fs too.  For instance, cr_ctx just becomes
> crfs_sb.  For things like dumping in parallel, we get locking and
> lifetime rules for free from the vfs.

Well, 'cr_ctx' is per-checkpoint, while crfs_sb will single for the
entire system. So you'll need to add something per checkpoint anyway.

What other concepts get easier ?

Oren.
