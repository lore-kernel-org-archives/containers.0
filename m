From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC cr-pipe-v13][PATCH 2/3] Checkpoint open pipes
Date: Sat, 07 Feb 2009 13:54:33 +0100
Message-ID: <498D8489.6090904@fr.ibm.com>
References: <1233091395-24582-1-git-send-email-orenl@cs.columbia.edu>
	<1233091395-24582-4-git-send-email-orenl@cs.columbia.edu>
	<498AB553.3090902@fr.ibm.com>
	<20090205202637.4d4f4a29@thinkcentre.lan>
	<1233940315.20090.120.camel@nimitz> <498C715B.4050303@fr.ibm.com>
	<1233941048.20090.123.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1233941048.20090.123.camel@nimitz>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> On Fri, 2009-02-06 at 18:20 +0100, Cedric Le Goater wrote:
>>> Sleeping inside mutexes is OK.  In general, they're drop-in compatible
>>> with semaphore behavior.
>> what about the vfs_write() ? 
> 
> Unless vfs_write() can come back and take the same mutex, I still think
> you're OK.  

generic_file_aio_write() locks the inode mutex.

C.
