From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [patch -mm 1/5] mqueue namespace : add struct mq_namespace
Date: Wed, 3 Oct 2007 09:56:44 -0700
Message-ID: <20071003165644.GA338@us.ibm.com>
References: <20071002084608.149781400@fr.ibm.com>
	<20071002084906.477406083@fr.ibm.com> <47020A29.9060403@sw.ru>
	<470219BC.3050702@fr.ibm.com>
	<m1ir5plr3c.fsf@ebiederm.dsl.xmission.com>
	<470237C7.5000902@fr.ibm.com> <20071002163020.GA11207@us.ibm.com>
	<47034868.5010505@fr.ibm.com>
	<20071003135955.GA7934@sergelap.austin.ibm.com>
	<4703A30F.2010007@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4703A30F.2010007-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Cedric Le Goater [clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
| > I think you and Eric (and I) are disagreeing about those limitations.
| > You take it for granted that a sibling pidns is off limits for signals.
| > But the signal wasn't sent using a pid, but using a file (in SIGIO
| > case).  So since the fs was shared, the signal should be sent.  An
| > event happened, and the receiver wants to know about it.
| 
| seen that way I agree. 
| 
| si_code is set to SI_MESGQ, but what do we put in si_pid ? 0 ?
| 
| we could use the si_errno to pass extra info, like the sending process 
| lives in a // world ...

Does the receiver need to know that sender is in a // world ? 

| 
| C.
