From: "Peter Dolding" <oiaohm@gmail.com>
Subject: Re: LSM and Containers
Date: Thu, 25 Oct 2007 09:07:52 +1000
Message-ID: <e7d8f83e0710241607k6d7ed6f8m2e7418478ef8cbb0@mail.gmail.com>
References: <200710220224.l9M2Og5t020815@sapphire.spiritone.com>
	 <20071022035954.GA30991@kroah.com> <471CE238.5040107@qumranet.com>
	 <e7d8f83e0710221559i6b14469fjebceee12c6dec98e@mail.gmail.com>
	 <471D8877.5030901@crispincowan.com>
	 <20071023133210.GC3086@sergelap.austin.ibm.com>
	 <471E3610.7030102@crispincowan.com> <471E8CD6.9060305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <471E8CD6.9060305@gmail.com>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
To: linux-security-module@vger.kernel.org, Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

The other thing you have not though of and is critical.  If LSM is the
same LSM across all containers.  What happens if that is breached and
tripped to disable.  You only want to loss one container to a breach
not the whole box and dice in one hit.  Its also the reason why my
design does not have a direct link between controllers.  No cascade
threw system to take box and dice.

The more I look at it more holes I find why the current LSM model just
cannot keep on existing with Containers.   Its not the best option.
Hacking it to work with containers is only creating risks of more
problems.  The LSM model as also breed that problem of not sharing
security tech advantages to everyone.  Ie if they don't use our LSM
they don't need/deserve our defense.

Different LSM per container from a security point of view appears
critical.  Sorry to say redesign from the ground up time everyone.
Its a round peg into a square hole yes you can bash it in but it will
never fit right.

Peter Dolding

ps sorry for going on so long I just see this as a major problem.   If
you have a solution to it tell me.  Since a cut line has be put
somewhere with containers.
