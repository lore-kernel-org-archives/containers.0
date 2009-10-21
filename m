From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Porting checkpoint system to arm
Date: Wed, 21 Oct 2009 08:29:32 -0500
Message-ID: <20091021132932.GA7731@us.ibm.com>
References: <44a110670910201851p7dade4b1if41eefae3ac2a518@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <44a110670910201851p7dade4b1if41eefae3ac2a518-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jerf gefera <jgefera-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Jerf gefera (jgefera-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> hi all,
> I am porting checkpoint system to arm, it seems(because restarting is not
> fine, i only can say it seems) that the checkpointing is fine, but when i
> restart the process from image file, then error occurs.
> The error is located in _cr_kread function in file sys.c, the return of
> vfs_read() is 0. I do not know what is wrong, i hope you can point it out
> for me.
> Thank you very much!
> best wishes,
> fera

Can you send us:
	1. the checkpoint file
	2. the relevant dmesg() output for the checkpoint and restart?
	3. perhaps try restart with the -vd options and send us that
	   output?
	4. if possible, a git url to your kernel code?

thanks,
-serge
