From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 1/1][RFC] do not sys_reboot when not in init_pid_ns
Date: Sun, 2 Nov 2008 17:04:14 -0600
Message-ID: <20081102230414.GA11149@us.ibm.com>
References: <490CEDA0.6020800@fr.ibm.com>
	<54333.2001:16d8:ff15:101:219:d2ff:fed5:8193.1225584965.squirrel@intranet>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <54333.2001:16d8:ff15:101:219:d2ff:fed5:8193.1225584965.squirrel@intranet>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Hokka Zakrisson <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Daniel Hokka Zakrisson (daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org):
> Daniel Lezcano wrote:
> >
> 
> Wouldn't it be better to simply remove CAP_SYS_BOOT from containers
> until sys_reboot emits some signal to userspace to restart/halt the
> container? (This is what we do in Linux-VServer.)
> 
> -- 
> Daniel Hokka Zakrisson

Yeah that makes more sense to me.

Note that otherwise your patch still lets the container mess with
sys_kexec_load(), for instance.

-serge
