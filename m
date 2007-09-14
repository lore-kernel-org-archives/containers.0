From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [NETNS45][patch 1/1] remove udp rover port
Date: Fri, 14 Sep 2007 10:04:45 -0600
Message-ID: <m17imt2pya.fsf@ebiederm.dsl.xmission.com>
References: <20070914154820.310553772@mai.toulouse-stg.fr.ibm.com>
	<20070914154935.128983162@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070914154935.128983162-WECHFHqYCmGD/CxQmPlnQ0FT0OZdM7KVQQ4Iyu8u01E@public.gmane.org>
	(dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org's message of "Fri, 14 Sep 2007 17:48:21 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org writes:

> From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
>
> in net-2.6.24, the algorithm which choose a port is changed. The rover
> port is no longer a global static variable, it is computed dynamically
> with net_random, each time a get_port call is done.
>
> So no need to have it in the network namespace

Good catch.  Thanks.

Eric
