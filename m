From: Michael Holzheu <holzheu-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [CRIU] [Announce] CRIU v3.3 (Crystal Pelican)
Date: Wed, 19 Jul 2017 13:19:59 +0200
Message-ID: <20170719131959.729aaf67@TP-holzheu>
References: <d711f22a-6661-dac9-6a6a-2f559baaa153@virtuozzo.com>
	<20170719113130.6f1d02cc@TP-holzheu>
	<69321954-b9cf-949b-08bd-0ded138f5ea0@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <69321954-b9cf-949b-08bd-0ded138f5ea0-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Cc: CRIU <criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alice Frosi <alice-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Am Wed, 19 Jul 2017 12:55:47 +0300
schrieb Pavel Emelyanov <xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>:

> On 07/19/2017 12:31 PM, Michael Holzheu wrote:
> > Am Tue, 18 Jul 2017 22:01:35 +0300
> > schrieb Pavel Emelyanov <xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>:
> > 
> >> Hello, everyone!
> >>
> >> The new version is out. Most of the changes this time are preparation for future new
> >> features and optimizations, that hasn't yet been well tested and polished.
> >>     
> >> However, we have several new features. The most important one is the --tcp-close
> >> option to help migration of Docker containers, that constantly change their IP address.
> >>     
> >> And, as usually, a set of bugfixes.
> > 
> > Hi Pavel,
> > 
> > What are your plans for the s390 support - version 3.4?
> 
> Yup. Once the Travis job is in working state (so that I can validate the release
> is at least building on non-default arch) all s390 patches will be moved to
> master and released.

In principle the travis job for s390 is working now:

 - https://travis-ci.org/xemul/criu/jobs/255093541

> 
> We're doing monthly releases, so the 3.4 will happen in the middle of August.

Sounds good!

Michael
