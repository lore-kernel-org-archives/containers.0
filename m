From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [Devel] [PATCH] pidns: Place under CONFIG_EXPERIMENTAL (take
 2)
Date: Sun, 28 Oct 2007 09:12:34 -0700
Message-ID: <4724B4F2.7070500@goop.org>
References: <CBC546DD07068244AEC110EFEDA58B7235893F@excite.int.sw-soft.com>	<m1ve8ty1tq.fsf@ebiederm.dsl.xmission.com>	<20071027002448.GH30533@stusta.de> <m18x5puyw7.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754999AbXJ1QMp@vger.kernel.org>
In-Reply-To: <m18x5puyw7.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Adrian Bunk <bunk@kernel.org>, Kir Kolyshkin <kir@swsoft.com>, containers@lists.osdl.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, kir@openvz.org
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Roughly that sounds like CONFIG_EXPERIMENTAL to me.  But I would
> be happy to hear if someone has a better idea.
>   

Rather than overload an existing config option, why not add one with the
specific semantics you want: CONFIG_UNSTABLE_UABI.  The problem seems
like one which which may occur again, though one hopes not too often.  I
guess the risk is that people will leave their subsystems depending on
it permanently (sysfs?), so it ends up being set all the time and
becomes as useless as EXPERIMENTAL...

    J
