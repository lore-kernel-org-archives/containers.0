From: John Paul Walters <jpnwalters-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: multi-threaded app fails to restart
Date: Mon, 19 Jul 2010 16:27:30 -0400
Message-ID: <AANLkTimpXSXQr1wew1wvZKnBFsOXD7f2tblY4EGmJoFM@mail.gmail.com>
References: <AANLkTilxfsYGyYLwO__VmDLSFQ_s_Qe03G49kIEztVja@mail.gmail.com>
	<1279569285.25071.98.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1279569285.25071.98.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

>> Ghost state Success
>> [ 3210.330285] [4031:4031:c/r:pgarr_release_pages:102] total pages 0
>> [ 3210.330288] [4031:4031:c/r:do_restart:1451] sys_restart returns -512
>>
>> Any thoughts?
>
> There were two patches posted to the containers list on 11 July - "fix
> task tree traversal for threads" and "save/restore 'sysenter_return' for
> threads".  Can you try with those on top of ckpt-v22-dev?
>
>
>

Hi Nathan,

Thanks for your help.  I applied the two patches as you suggested.
They fixed the first of the two bad sys_restart return values, but the
final one (quoted above, for what it's worth) still returns -512.
When I use the -d -v switches to restart, it appears to work (no error
messages are returned), but only the main thread is restored while the
second thread is not.

JP
