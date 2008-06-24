From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [PATCH 1/2][cryo] Save/restore state of unnamed pipes
Date: Tue, 24 Jun 2008 10:58:53 -0700
Message-ID: <20080624175853.GA17526@us.ibm.com>
References: <20080624032343.GA27394@us.ibm.com>
	<20080624032536.GA27493@us.ibm.com>
	<20080624161531.GC14761@us.ibm.com>
	<20080624173804.GB26945@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080624173804.GB26945-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
| > | +		} else
| > | +			ERROR("Unexpected item, '%s'\n", item);
| > | +	}
| > | +	DEBUG("restore_fifo() fd %d, len %d, got 'END FIFO'\n",
| > | +			fifofdinfo->fi_fd, fifofdinfo->fi_length);
| > | +	return 0;
| > | +}
| > 
| > fifofdinfo can be NULL if application does not have any fifos and
| > the above DEBUG() will SIGSEGV. Following updated patch fixes this.
| > Thanks Serge for reporting the bug.
| 
| Thanks, Suka.  This version works for both pipe and sleep testcases.
| 
| Though, interestingly, it segfaults on the -lxc kernel.  It succeeds on
| a recent -git from Linus' tree, though.

I have been testing 2.6.25-mm1.

I run into the semun_undo underflow bug with -lxc. Is that the same
bug you are running into ?

| 
| So I'm about to apply these on git://git.sr71.net/~hallyn/cryodev.git
| 

Thanks,

Suka
