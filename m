From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [RFC][PATCH][cryo] Save/restore state of unnamed pipes
Date: Tue, 17 Jun 2008 15:55:57 -0700
Message-ID: <20080617225557.GA13205@us.ibm.com>
References: <20080617212950.GB11826@us.ibm.com>
	<20080617223039.GB26942@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080617223039.GB26942-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

<snip>
| > +
| > +	rc = read(fifo_fd, &c, 1);
| > +	if (rc != -1 && errno != EAGAIN) {
| 
| 	Won't errno only be set if rc == -1?  Did you mean || here?

Yes I meant ||. I also had 'errno = 0' before the read, but seem
to have deleted it when I moved code around.

<snip>

| > +		} else if (S_ISFIFO(fdinfo->mode)) {
| > +			int pipefds[2] = { 0, 0 };
| > +
| > +			/*
| > +			 * We create the pipe when we see the pipe's read-fd.
| > +			 * Just ignore the pipe's write-fd.
| > +			 */
| > +			if (fdinfo->flag == O_WRONLY)
| > +				continue;
| > +
| > +			DEBUG("Creating pipe for fd %d\n", fdinfo->fdnum);
| > +
| > +			t_d(PT_PIPE(pid, pipefds));
| > +			t_d(pipefds[0]);
| > +			t_d(pipefds[1]);
| > +
| > +			if (pipefds[0] != fdinfo->fdnum) {
| > +				DEBUG("Hmm, new pipe has fds %d, %d "
| > +					"Old pipe had fd %d\n", pipefds[0],
| > +					pipefds[1], fdinfo->fdnum); getchar();
| 
| Can you explain what you're doing here?  I would have expected you to
| dup2() to get back the correct fd, so maybe I'm missing something...

You are right, I should use dup2() here.

Will send an updated patch.

Thanks,

Suka
