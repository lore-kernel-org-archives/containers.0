From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Containers vs. OpenVZ
Date: Tue, 17 Aug 2010 17:24:16 -0700
Message-ID: <20100818002416.GG3648@count0.beaverton.ibm.com>
References: <20100817103339.GA8495@nibiru.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100817103339.GA8495-q9I3ByPDOfiE+EvaaNYduQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Enrico Weigelt <weigelt-EU+a56NjgY8@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Aug 17, 2010 at 12:33:40PM +0200, Enrico Weigelt wrote:
> 
> Hi folks,
> 
> 
> could anyone please point out the difference main difference 
> between linux-containers and openvz ? It is possible to replace
> ovz by linux-containers yet ?
> 
> thx

Hi,

	At the very least there is no kernel code in mainline for
checkpoint/restart of containers at this time. We're still working on
patches for that feature. So that's one major difference between
"linux-containers" and openvz.

	I'm sure there are other differences which openvz and lxc folks
can point out but this is the one I'm presently most-keenly aware of. I
haven't had time to follow what's new with openvz so I'll leave the
rest of the comparison to other folks.

Cheers,
	-Matt Helsley
